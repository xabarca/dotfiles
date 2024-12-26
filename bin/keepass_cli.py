from pykeepass import PyKeePass,create_database
from pykeepass.exceptions import CredentialsError
from argparse import ArgumentParser
from os.path import exists

# ---------------------
def ask_password():
    import getpass
    p = getpass.getpass(prompt='Type master password: ')
    p2 = getpass.getpass(prompt='Retype it: ')

    if p == p2:
        print('Password entered:', p)
    else:
        print('Entered passwords do not match')
        exit()

# ---------------------
def open_database(dbpath, dbpwd, keyfile):
    if not exists(dbpath):
        print('database not exists')
        exit()
    try:
        kp = PyKeePass(dbpath, password=dbpwd, keyfile=keyfile)
        return kp
    except CredentialsError:
        print('Invalid credentials')
        exit()
    else:
        return kp

# ---------------------
def change_password(dbpath, dbpwd, keyfile, newpwd, newkeyfile=None ):
    kp = open_database(dbpath, dbpwd, keyfile)
    kp.password = newpwd
    if newkeyfile:
        kp.keyfile = newkeyfile
    kp.save()

# ---------------------
def create(dbpath, password, keyfile=None):
    kp2 = create_database(dbpath, password=password, keyfile=keyfile)
    kp2.save()

# ---------------------
def add_entry(dbpath, dbpwd, keyfile, entryname, entrypwd):
    kp = open_database(dbpath, dbpwd, keyfile)
    if '/' in entryname:
        data = entryname.split('/', maxsplit=1)
        groupname = data[0]
        name = data[1].replace("/", "_")
        group = kp.find_groups(name=groupname, first=True)
        if not group:
            group = kp.add_group(kp.root_group, groupname)
    else:
        group = kp.root_group
        name = entryname

    kp.add_entry(group, name, name, entrypwd )
    kp.save()

# ---------------------
def get_secret(dbpath, dbpwd, keyfile, entryname):
    secret = None
    kp = open_database(dbpath, dbpwd, keyfile)
    if '/' in entryname:
        data = entryname.split('/')
        groupname = data[0]
        name = data[1]
        group = kp.find_groups(name=groupname, first=True)
        if group:
            entry = kp.find_entries(group=group, title=name, first=True)
            if entry:
                secret = entry.password
    else:
        group = kp.root_group
        entry = kp.find_entries(group=group,  title=entryname, first=True)
        if entry:
            secret = entry.password
    kp.save()
    return secret




# Define the parser
parser = ArgumentParser(description='Short sample app')

parser.add_argument('--password',
                    action="store",
                    dest='password')
parser.add_argument('--database',
                    action="store",
                    dest='database')
parser.add_argument('--keyfile',
                    action="store",
                    dest='keyfile')
parser.add_argument('--entry',
                    action="store",
                    dest='entry')
parser.add_argument('--entrypwd',
                    action="store",
                    dest='entrypwd')
parser.add_argument('--newpwd',
                    action="store",
                    dest='newpwd')
parser.add_argument('--getsecret', action='store_true')
parser.add_argument('--create', action='store_true')
parser.add_argument('--changepwd', action='store_true')

# Now, parse the command line arguments and store the 
# values in the `args` variable
args = parser.parse_args()


# Validate keyfile path exists
keyfile=None
if args.keyfile:
    if not exists(args.keyfile):
        print('keyfile not found')
        exit()
    else:
        keyfile = args.keyfile


if args.create:
    if not args.database or not args.password:
        print('database and password must be specified')
        exit()
    create( args.database, args.password, keyfile )
elif args.changepwd:
    if not args.database or not args.password:
        print('database and password must be specified')
        exit()
    if not args.newpwd:
        print('new password must be specified')
        exit()
    change_password( args.database, args.password, keyfile, args.newpwd )
elif args.getsecret:
    if not args.database or not args.password:
        print('database and password must be specified')
        exit()
    if not args.entry:
        print('entry must be specified')
        exit()
    secret = get_secret( dbpath=args.database, dbpwd=args.password, keyfile=keyfile,
                entryname=args.entry)
    print(secret)
else:
    if not args.database or not args.password:
        print('database and password must be specified')
        exit()
    if not args.entry or not args.entrypwd:
        print('entry and entrypwd must be passed')
        exit()
    add_entry( dbpath=args.database, dbpwd=args.password, keyfile=keyfile,
                entryname=args.entry, entrypwd=args.entrypwd)

