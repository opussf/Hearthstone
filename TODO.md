TODO.md

# Possible next steps:

[ ] Have time sensitive list
	Make a list of toys for any modifier that exists until a time stamp.  Takes priority.
	To Allow one to focus on a holiday, that auto expires.  Instead of using a different modifier.

[ ] Configure when the macro updates
	Right now it is auto tied to the PLAYER_ENTERING_WORLD event, or manually with `/hs update`.
	Allow it to be tied to other events, or even remove the connection to the current event.

[ ] Make some selections char specific.

[ ] Allow it to support multiple macros, with different mod lists for each.
	HS macro
	Toy macro
	etc macro


[ ] Delay the Random choice until a few seconds after Loading screen is finished
	Do this at least for the first time.
	GetItemCount does not always return the correct value right at startup.

	Use Frame:SetScript to register and remove the OnUpdate script.
	Set a delay of 1 or 2 seconds.


[ ] Look into making an expanible icon sort of thing  (mage portal spells)
