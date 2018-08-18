import sys
from the_real_goto import load_magic, save_magic, list_words


def main():
	if len(sys.argv) == 0:
		print(current_project())
		exit(0)

	action = sys.argv[0]
	arguments = sys.argv[1:]

	if action == "list":
		print(list_projects())
		exit(0)

	if action == "add":
		add_project(arguments)
		exit(0)

	switch_project(arguments)
	exit(0)




def current_project()



if __name__ == '__main__':
	main()