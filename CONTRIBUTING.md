# USN Horizon Git Standard

This document describes rules, best practices and workflows for contributing in the repositories of USN Horizon.
<br>
The USN Horizon Git Standard is based on the [GitHub Flow](https://docs.github.com/en/get-started/using-github/github-flow).

## Branch naming convention

The *main*-branch is the default, stable branch. Its content is in a ready and tested state.
<br>
When a new task is started, a branch is created branching off *main*.

The naming convention of branches is as follows:
```
<branch-type>/<short-description>
```

An example of a branch could be: *feature/sensor-interface*

|Branch Type|Use case|
|---|---|
|feature|New/additional features and functionality|
|fix|Bugfixes and corrections|
|test|Tests|
|refactor|Restructuring and refactors|
|docs|Documentation|
|task|General work / No fitting branch type|

## Workflow (Step by Step)
<ol>
<li>Create a branch. Give it a fitting type and name.</li>
<li>Make changes on this branch. Commit and push as usual.</li>
<li>When finished, create a pull request.</li>
<li>If merge conflicts arise, resolve them.</li>
<li>Review the pull request with others and address eventual comments.</li>
<li>Merge the pull request into main.</li>
<li>Delete the branch.</li>
</ol>

## Best practices

[Here](https://github.com/StevenGonzalez/pull-request-playbook/blob/main/README.md) is a good writeup on best practices for pull requests with examples.

- The name of a pull request should be clear and summarizing. It should also be marked with its branch type.
    - A good name: [fix] Fixed memory leak in FunctionName()
    - A bad name: Updated stuff
- The description of a pull request is the most important part, it should describe:
    - **What was changed**
    - **Why it was changed**
    - **How it works** (for complex changes)
    - **Testing** (If relevant)

    Keywords are good enough, but remember: **The goal is to make sure someone else will get a clear view of what the pull request is about at a glance**.
- Reviewing pull requests is just as important to the workflow as writing the code. Without reviews, the changes will never be integrated into the project! **Make sure to set aside some time to review code you've been assigned to review!**
- If a pull request has gone stale (not touched in a long while), notify your team and make sure it gets seen.

## Future improvements

- Setup labels for GitHub pull requests. Easier to organize and locate.
