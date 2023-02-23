import textwrap
import time
from getpass import getpass


def init():
    dbname = input("Name [sms]: ") or "sms"
    user = input("User [postgres]: ") or "postgres"
    host = input("Host [localhost]: ") or "localhost"
    port = input("Port [5432]: ") or "5432"
    password = None
    while not password:
        password = getpass("Pass: ")

    return f"dbname={dbname} user={user} host={host} port={port} password={password}"


def timeit(f):
    def wrapper(*args, **kwargs):
        st = time.perf_counter()
        result = f(*args, **kwargs)
        et = time.perf_counter()
        tt = et - st
        ak = textwrap.shorten(f"{args}, {kwargs}", width=50, placeholder="...")
        print(f"f: {f.__name__} a: [{ak}] t: {tt:.4f} sec")
        return result
    return wrapper
