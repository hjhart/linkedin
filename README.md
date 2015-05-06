# README

## What is it?

This simple selenium script will allow you to accept all of your LinkedIn 
invitations. 


## How?

Run the script by doing:

```bash
bundle install
USERNAME='yourusername@gmail.com' PASSWORD='somethingsomething' be ruby accept_invitations.rb
```

If LinkedIn detects your log in as "fishy" it will do a Two-Step Verification process.
If LinkedIn detects you as a bot, it will ask you to enter a captcha.
In either case, firefox will pause for you to enter in the information.
When you've finished, make sure to exit out of the `binding.pry` to continue.

To open up a pry interface (e.g. to query the database)

```
be ruby console.rb
```
