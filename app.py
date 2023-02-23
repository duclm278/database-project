import psycopg2
from helpers import *
from pprint import pprint
from psycopg2.extras import execute_values


def main():
    # Settings
    info = init()
    conn = psycopg2.connect(info)
    curs = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)


if __name__ == '__main__':
    main()
