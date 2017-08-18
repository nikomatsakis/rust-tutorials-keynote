all:
	markdown 10-Ownership.md > 10-Ownership.html
	scp 10-Ownership.html scf:web/tutorial-script/
