BashBudgetPro
=============

A simple budgeting application that is run entirely by a bash script.  This is ovbiously not the best language
for implementing this functionality, but it was a learning experiment for improving my bash skills.  In fact, several interesting problems arose that I would have not been challenged with if I had implemented it in another language.

There are only 6 accounts used in this application.  Each time the budget is saved, a backup is made in
the backup folder and the current totals are saved in the budget_data.txt file.  Simply run the script in a Unix terminal to start the program.

Commands:

1) view balances

2) expense [account] [amount]

3) transfer [fromAcct] [toAcct] [amount]

4) save

5) exit


To-Do's:

- Add month closing abilities
- Create init process that allows custom creation of accounts
- Maintain expense history and develop a way to display it
- Further test corner cases with dollar amounts
