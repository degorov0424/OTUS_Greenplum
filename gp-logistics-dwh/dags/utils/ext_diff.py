from utils.ext_diff_templates import TEMPLATES


def read_last_batch_ts(greenplum_hook, source_name):
    rows = greenplum_hook.get_records(
        "SELECT last_batch_ts FROM meta.batch_history WHERE source_name = %s",
        parameters=(source_name,),
    )
    last_batch_ts = rows[0][0] if rows and rows[0][0] is not None else None
    return last_batch_ts.strftime("%Y-%m-%d %H:%M:%S") if last_batch_ts is not None else "1970-01-01 00:00:00"

def _split_statements(block):
    statements = []
    for raw_chunk in block.split(";"):
        code_lines = [line for line in raw_chunk.splitlines()
                      if not line.strip().startswith("--")]
        statement = "\n".join(code_lines).strip()
        if statement:
            statements.append(statement)
    return statements
    
def create_ext_table(greenplum_hook, pg_table):
    
    rows = greenplum_hook.get_records(
        "SELECT to_regclass('ext.%s_diff')" % pg_table
    )
    if rows and rows[0][0] is not None:
        return False
        
    block = TEMPLATES.get(pg_table)
    if not block:
        raise ValueError(f"нет шаблона ext.{pg_table}_diff")
    
    statements = _split_statements(block)
    connection = greenplum_hook.get_conn()
    try:
        with connection.cursor() as cursor:
            for statement in statements:
                cursor.execute(statement)
        connection.commit()
    except Exception:
        connection.rollback()
        raise
    finally:
        connection.close()
    return True
