@echo off

IF [%1] EQU [] (
    ECHO Please supply a path to a file as argument to sign.
    EXIT
)

ECHO Starting signing process...

signtool sign /a /tr http://timestamp.globalsign.com/tsa/r6advanced1 /td SHA256 /fd SHA256 %1

ECHO Done.