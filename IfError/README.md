If some error happened you do want to delete whatever is left over on the local nodes storages.

Here we do that by running a very small Sbatch on each node on which we delete all files on /tmp. They are user-protected, so we cant delete other users stuff.

Change the nodes on deleteScript.sh to your nodes if you want to use it.
