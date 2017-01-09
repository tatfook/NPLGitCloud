## Git Related C Code
1. addFile only create a initial commit without actually adding the file if the repository does not have any commit yet (a new one)
	Currently in lua2git.lua file, I call addFile function twice for a new repo. (This will work, but it definitely is not elegant)
	Will fix this problem very soon.
