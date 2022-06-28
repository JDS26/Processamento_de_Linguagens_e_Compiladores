%option noyywrap

%%
[+\-*/=;:()\[\]\{\}|\r]    {return (yytext[0]);}
"=="                {return (IG);}
"~="                {return (DIF);}
">="                {return (IMA);}
">"                 {return (MA);}
"<="                {return (IME);}
"<"                 {return (ME);}
"++"                {return (INC);}
"--"                {return (DEC);}
(?i:e)              {return (E);}
(?i:ou)             {return (OU);}
(?i:scan)           {return (SC);}
(?i:for)            {return (FOR);}
(?i:se)             {return (SE);}
(?i:ret)            {return (RET);}
(?i:senao)          {return (SENAO);}
(?i:do)             {return (DO);}
(?i:true)           {return (TRUE);}
(?i:false)          {return (FALSE);}
(?i:mod)            {return (MOD);}
(?i:write)          {return (WRITE);}

[A-Za-z]+           {yylval.valC= strdup(yytext);return (ID);}

[0-9]+  			{yylval.valN = atoi(yytext); return (NUM);}
.|\n                {;}
%%