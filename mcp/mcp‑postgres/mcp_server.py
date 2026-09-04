from mcp.server.fastmcp import FastMCP
import psycopg2
import os
from dotenv import load_dotenv

load_dotenv()
mcp = FastMCP("postgres‑tool")

# 数据库连接串，从.env读取
DB_DSN = os.getenv("DB_DSN")

@mcp.tool()
def run_sql(sql: str) -> str:
    """
    执行原生PostgreSQL SQL，支持DML、DDL、权限语句
    Args:
        sql: 完整sql语句
    Returns:
        执行结果文本
    """
    conn = psycopg2.connect(DB_DSN)
    cur = conn.cursor()
    try:
        cur.execute(sql)
        conn.commit()
        if cur.description:
            rows = cur.fetchall()
            return str(rows)
        return "执行成功"
    except Exception as e:
        conn.rollback()
        return f"执行失败:{str(e)}"
    finally:
        cur.close()
        conn.close()

if __name__ == "__main__":
    mcp.run()
