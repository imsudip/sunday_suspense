# open readme.md and update the section between <UPDATE> </UPDATE> tags

import re
import datetime
import os


def update_readme():
    curr = os.getcwd()
    # go out of server folder and search for readme.md
    loc = os.path.join(curr, '..', 'readme.md')
    # current date and time in format: 01/02/2022 12:00:00 AM
    date = datetime.datetime.now().strftime("%m/%d/%Y %I:%M:%S %p")
    l = "Data last updated: " + date
    # update the section between <UPDATE> </UPDATE> tags
    readme = open(loc, 'r').read()
    readme = re.sub(r'(?<=<UPDATE>).*(?=</UPDATE>)',
                    l, readme, flags=re.DOTALL)
    # save the updated readme
    open(loc, 'w').write(readme)
