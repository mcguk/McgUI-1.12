AfterCast - Perform action after a cast
---------------------------------------------------------------------------
This is a fairly simple addon for performing actions based on the success
or failure of a cast. Usage is as follows

/aftercast /smile
/aftercast +fail /cry
/cast Frostbolt(Rank 2)

For this example, if the spell succeeds then you'll smile, if it
fails, then you'll cry. If it is interrupted then nothing will happen.

Events you can use are:

+done	     At the end of successful casting (Default if no event given)
+fail        If the spell fails
+interrupt   If the spell is interrupted
+start       When spell starts casting (Fires before done for instant spells)

Aftercasts apply to the next spell which occurs, and then is reset, you can
set up one of each event before each cast.

These functions can also be gotten at via lua functions

AfterCast(doneAction, failAction);
   Shortcut to set up the 2 most common actions, either can be nil.

AfterCastOn(event, action)
   Set up a specific action (use without the +, so "done", "fail", etc)

AfterCastReason([clearFlag])
   Return the stop reason ("done"/"interrupt"/"fail") for the last cast
   (nil if none have stopped since the last clear).. if clearFlag is
   present and true then resets status after return.

---------------------------------------------------------------------------
REVISIONS

Version 0.6 - 2006-06-19
   * Added spellcast failure tests for normal casting states to handle
     target-death-during-cast scenarios.

Version 0.5.1 - 2006-04-10
   * Removed accidental debugging line.

Version 0.5 - 2006-04-09
   * Updated for version 1.10 (Completely rewritten event engine)

Version 0.4 - 2005-09-12
   * Added AfterCastReason([clearFlag]) function

Version 0.3 - 2005-02-18
   * Fixed interrupt event issue 

Version 0.2 - 2005-01-30
   * Fixed issue with /p and other chat functions failing to work
   * Added a 'fake' start event for instant cast spells.
