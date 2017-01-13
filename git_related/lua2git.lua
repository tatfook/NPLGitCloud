require("gitcore");

text = "sample content";
newText = "new sample";
repo = "new_repo";
isBare = 1;
commitMsg = "first commit";
filePath = "newtest.txt";

print(repoInit(repo, isBare));
print(addFile(repo, filePath, commitMsg, "master", "", string.len(text), text));
print(addFile(repo, filePath, commitMsg, "master", "", string.len(text), text));
print(getContent(repo, "master", filePath));
print(updateFile(repo, filePath, "new commit", "master", "", string.len(newText), newText));
print(getContent(repo, "master", filePath));
print(traverseTree(repo, "master")); -- for the get sha list API
print(deleteFile(repo, filePath, "delete file commit", "master", ""));
print(deleteRepo(repo));
