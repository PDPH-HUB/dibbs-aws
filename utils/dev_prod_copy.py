import logging
import sys
from sqlalchemy import create_engine, text

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s",
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler("migrate_ecr_viewer.log"),
    ],
)
log = logging.getLogger(__name__)

SOURCE_CONN = (
    "mssql+pyodbc://EHSALIDSQL02/DPH_HealthReporting_Dev"
    "?driver=ODBC+Driver+17+for+SQL+Server&trusted_connection=yes"
)
DEST_CONN = (
    "mssql+pyodbc://DPHALIPSQL/DPH_HealthReporting"
    "?driver=ODBC+Driver+17+for+SQL+Server&trusted_connection=yes"
)

SCHEMA = "ecr_viewer"
BATCH_SIZE = 10000

# insert order respects FK dependencies
INSERT_ORDER = [
    "user",
    "program_area",
    "ecr_data",
    "ecr_rr_conditions",
    "patient_address",
    "ecr_labs",
    "ecr_rr_rule_summaries",
    "condition_reference",
    "user_program_area",
    "audit_log",
]

FK_CONSTRAINTS = [
    ("user",                  "FK__user__author_uui__19120B7B"),
    ("program_area",          "FK__program_a__autho__1DD6C098"),
    ("user_program_area",     "FK__user_prog__user___20B32D43"),
    ("user_program_area",     "FK__user_prog__progr__21A7517C"),
    ("condition_reference",   "FK__condition__progr__2483BE27"),
    ("ecr_rr_conditions",     "ecr_rr_conditions_fk_eicr_id"),
    ("ecr_labs",              "ecr_labs_fk_eicr_id"),
    ("patient_address",       "patient_address_fk_eicr_id"),
    ("ecr_rr_rule_summaries", "ecr_rr_rule_summaries_fk_ecr_rr_conditions"),
]

NONCLUSTERED_INDEXES = [
    ("audit_log",    "UQ__audit_lo__7F4279313F719124"),
    ("program_area", "UQ__program___72E12F1B1D337B7D"),
    ("user",         "UQ__user__AB6E6164370350A5"),
]


def get_row_count(conn, table):
    result = conn.execute(text(f"SELECT COUNT(*) FROM [{SCHEMA}].[{table}]"))
    return result.scalar()


def get_columns(conn, table):
    result = conn.execute(text(f"""
        SELECT COLUMN_NAME
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = :schema AND TABLE_NAME = :table
        ORDER BY ORDINAL_POSITION
    """), {"schema": SCHEMA, "table": table})
    return [row[0] for row in result]


def drop_fk(conn, table, constraint):
    conn.execute(text(f"ALTER TABLE [{SCHEMA}].[{table}] DROP CONSTRAINT [{constraint}]"))
    log.info("dropped FK %s on %s", constraint, table)


def restore_fk(conn, table, constraint, child_col, parent_table, parent_col):
    conn.execute(text(f"""
        ALTER TABLE [{SCHEMA}].[{table}]
        ADD CONSTRAINT [{constraint}]
        FOREIGN KEY ([{child_col}])
        REFERENCES [{SCHEMA}].[{parent_table}] ([{parent_col}])
    """))
    log.info("restored FK %s on %s", constraint, table)


def migrate():
    src_engine = create_engine(SOURCE_CONN)
    dst_engine = create_engine(DEST_CONN, fast_executemany=True)

    with src_engine.connect() as src_conn, dst_engine.connect() as dst_conn:

        log.info("starting migration")

        log.info("dropping FK constraints on destination")
        for table, constraint in reversed(FK_CONSTRAINTS):
            drop_fk(dst_conn, table, constraint)
        dst_conn.commit()

        log.info("disabling nonclustered indexes on destination")
        for table, index in NONCLUSTERED_INDEXES:
            dst_conn.execute(text(f"ALTER INDEX [{index}] ON [{SCHEMA}].[{table}] DISABLE"))
            log.info("disabled index %s on %s", index, table)
        dst_conn.commit()

        log.info("beginning data transfer")
        for i, table in enumerate(INSERT_ORDER):
            try:
                total = get_row_count(src_conn, table)
                columns = get_columns(src_conn, table)
                col_list = ", ".join(f"[{c}]" for c in columns)
                placeholders = ", ".join(f":{c}" for c in columns)
                insert_sql = text(f"""
                    INSERT INTO [{SCHEMA}].[{table}] ({col_list})
                    VALUES ({placeholders})
                """)

                dst_conn.execute(text(f"TRUNCATE TABLE [{SCHEMA}].[{table}]"))
                dst_conn.commit()
                log.info("truncated %s", table)

                offset = 0
                batch_num = 0
                tables_remaining = len(INSERT_ORDER) - (i + 1)

                while True:
                    rows = src_conn.execute(text(f"""
                        SELECT {col_list} FROM [{SCHEMA}].[{table}]
                        ORDER BY (SELECT NULL)
                        OFFSET :offset ROWS FETCH NEXT :batch ROWS ONLY
                    """), {"offset": offset, "batch": BATCH_SIZE}).mappings().all()

                    if not rows:
                        break

                    dst_conn.execute(insert_sql, [dict(r) for r in rows])
                    dst_conn.commit()
                    batch_num += 1
                    offset += len(rows)
                    remaining = max(0, total - offset)
                    log.info(
                        "table %s: inserted batch %d (%d/%d rows) | %d rows remaining in table | %d tables remaining",
                        table, batch_num, offset, total, remaining, tables_remaining
                    )

                    if len(rows) < BATCH_SIZE:
                        break

                log.info("completed table %s: %d rows total", table, offset)

            except Exception as e:
                dst_conn.rollback()
                log.error("failed on table %s: %s", table, e)
                raise

        log.info("restoring FK constraints on destination")
        fk_meta = {}
        for child_table, fk_name in FK_CONSTRAINTS:
            row = src_conn.execute(text("""
                SELECT
                    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS child_col,
                    OBJECT_NAME(fk.referenced_object_id) AS parent_table,
                    COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS parent_col
                FROM sys.foreign_keys fk
                JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
                WHERE fk.name = :fk_name
                  AND OBJECT_SCHEMA_NAME(fk.parent_object_id) = :schema
            """), {"fk_name": fk_name, "schema": SCHEMA}).fetchone()
            if row:
                fk_meta[(child_table, fk_name)] = row

        for child_table, fk_name in FK_CONSTRAINTS:
            meta = fk_meta.get((child_table, fk_name))
            if meta:
                restore_fk(dst_conn, child_table, fk_name, meta[0], meta[1], meta[2])
        dst_conn.commit()

        log.info("rebuilding nonclustered indexes on destination")
        for table, index in NONCLUSTERED_INDEXES:
            dst_conn.execute(text(f"ALTER INDEX [{index}] ON [{SCHEMA}].[{table}] REBUILD"))
            log.info("rebuilt index %s on %s", index, table)
        dst_conn.commit()

        log.info("migration completed successfully")


if __name__ == "__main__":
    migrate()
