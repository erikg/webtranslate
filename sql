the tables are outlined in 'tables'.

When a packages pot file is imported into the database, it's automatically
added under the language of "C", which is what the msgid fields are made of
in the po files. The web page asks for a 'reference' language, and shows the
possible languages. If this is the first time a language has been adjusted, it
will only show "C" as a possible language. This is so the translator doesn't
need to know the same language as the programmer. It is preferable to use the
C locale as to avoid the semantic deterioration that comes with translating
something several times, but not required.

po files are composed of several entries, each having 6 components
	translator comments
	automatic comments
	reference
	flags
	msgid
	msgstr
We're not terribly interested in the comments, but we need the other 4 peices.
The messages table stores these four components for each 'session'. Each unique
id should be able to create a complete but uncommented .po file based on the
contents of the session and messages tables.


To show all possible peices of software in this database:
> select program,version from session group by program order by program asc;

To show all reference languages for program XXX:
> select id,language from session where program=XXX group by language order by 
  language asc;

To show all msg pairs for id XXX:
> select reference,flag,msgid,msgstr from messages where id=XXX;

To show all msgid for program XXX with YYY as a reference language:
> select id from session where program=XXX and language=YYY;
(store results in ZZZ since mysql is crappy and doesn't support subselects)
> select reference,flag,msgid,msgstr from messages where id=ZZZ;

(or, in a real RDBMS):
> select reference,flag,msgid,msgstr from messages where id=(
	select id from session where program=XXX and language=YYY);



