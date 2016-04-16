# GAP
Granular APL Project manager. For easy management of source code in external files.

## Why
In the last few years Dyalog has provided several new enhancements to their interpreter and changes to allow code to be stored in external text files that are loaded into the workspace and kept synchronised with changes made from within the workspace. The mechanism to store code external to the workspace is growing in complexity, supporting various modes of working with external files such as:

* versioning
* store code in Class/Namespace scripts
* store individual functions/variables/traditional namespaces in external files/folders

However, all these mechanisms still work with a workspace centric mindset. If I wanted to create a new project using external files, I can relatively easily create a load script that starts the interpreter and loads all files into the workspace. Similarly, if I have an existing application workspace I can issue a ]snap command to export the content to external files and generate a load script to rebuild the workspace.

What is missing in both the above scenarios is the ability to easily extend the codeset without having to remember to export the code to file and add it to the load script.

How about a script file centric mindset? An application that is primarily a collection of external files organised in folders with the ability to load it into the interpreter and work on it, extend with new namespaces, functions, classes etc. and rely on the editor to transparently update the external files as you go along. Without a source code management (SCM) system in place to version and track changes, this would be a disastrous approach.

Fortunately there are plenty of SCM tools available. GAP is a framework for developing APL applications with a script centric mindset in conjunction with your choice of SCM system.

## How
The framework comes with two files:

1. GAP.dyalog - the framework source
1. xload.dyapp - a load script that starts the interpreter and initialises the framework

### Start a new project
To start a new project, place the 2 files in the root of your project folder and double click the xload.dyapp file. Start writing some code and see it magically appear in the `src/` folder.

### Convert an existing application
Place the 2 files in the root of your project folder. Copy your existing code from another workspace or load it in with a load script. Call `⎕SE.GAP.Export './src'` and you are done. Happy coding!