#!/usr/bin/env python
# code: utf-8
'Goto - the magic project that takes you where you need to be, now.'
import sys
from gotomagic.handlers import *
from gotomagic.magic import GotoMagic
import gotomagic.text as text
from gotomagic.text import print_text
from gotomagic.githubmagic import GitHub


def usage():
    return """
    Goto - the magic traveler, how may I help you?

    Wondering how to change project?
     - consult my brother in command by typing:
        project help

    The basics
        - Adding a shortcut:        goto add <magicword> <url or path>
        - Updating a shortcut:      goto update <magicword> <url or path>
        - Removing a shortcut:      goto rm <magicword>

        - Show url of shortcut:     goto show <magicword>

        - Listing all shortcuts:    goto list
        - With the urls printed:    goto list -v

    Working with folders and files:
        - cd in terminal:           goto cd <magicword>
        - open folder in Finder:    goto open <magicword>
                                    goto -o <magicword>

    code - A specially magic magic word:
        If you add a shortcut
        to a folder,and name the
        shortcut "code";            goto add code <path to folder with code>
        - you may then do this:     goto subl
        and it opens
        Sublime Text in your folder.

    """


if __name__ == "__main__":
    jfile = sys.argv[1]
    magic = GotoMagic(jfile)

    if len(sys.argv) == 2:
        print(usage())
        exit(0)

    if len(sys.argv) > 2:
        if sys.argv[2] in ['help', '-h', '/?', '--help']:
            print(usage())
            exit(0)

        if sys.argv[2] == 'add':
            try:
                magic.add_shortcut(sys.argv[3], sys.argv[4])
                magic.save()
                print('Added magic word %s' % sys.argv[3])
                exit(0)
            except IndexError:
                if len(sys.argv) > 3:
                    print_text(
                        text.warning["missing_uri"],
                        magicword=sys.argv[3]
                    )
                else:
                    print_text(
                        text.warning["missing_magicword_and_uri"]
                    )
                exit(1)

        if sys.argv[2] == 'update':
            magic.update_shortcut(sys.argv[3], sys.argv[4])
            magic.save()
            print('Updated magic word %s' % sys.argv[3])
            exit(0)

        if sys.argv[2] == 'rm':
            try:
                magic.remove_shortcut(sys.argv[3])
                magic.save()
                print('Removed magic word %s' % sys.argv[3])
                exit(0)
            except Exception:
                print('Failed to remove magic word %s' % sys.argv[3])
                exit(1)

        if sys.argv[2] == 'show':
            magic.show_shortcut(sys.argv[3])
            exit(0)

        if sys.argv[2] == 'copy':
            copy_to_clipboard(str(magic.get_uri(sys.argv[3])))
            exit(0)

        if sys.argv[2] == 'list':
            magic.list_shortcuts(verbose=('-v' in sys.argv))
            exit(0)

        if sys.argv[2] == 'subl':
            try:
                open_sublime(magic['code'])
            except KeyError:
                print(text.warning["no_magicword_named_code"])
            exit(0)

        # Generating dynamic auto completion list
        # used by start_goto
        if sys.argv[2] == '--github-list':
            api = GitHub(magic['github'])
            if len(sys.argv) == 4:
                keys = api.search_for_url(sys.argv[3], return_keys=True)
                print("\n".join(keys))
            exit(0)

        # going to sub-url in github
        if sys.argv[2] == 'github':
            api = GitHub(magic['github'])
            if len(sys.argv) == 4:
                url = api.url_for(sys.argv[3])
                open_link(url)
            exit(0)

        if '-o' in sys.argv or '--open' in sys.argv or 'open' in sys.argv:
            open_folder(magic.get_uri(sys.argv[3]))
            exit(0)

        if sys.argv[2] == 'cd':
            open_terminal(magic.get_uri(sys.argv[3]))
            exit(0)
        # default
        open_link(magic[sys.argv[2]])
