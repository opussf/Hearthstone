# FEATURE.md

## onupdate_delay

The API calls to test the toys, and even the HearthStone existence do not work quite right, at the first load.

GetItemCount(), PlayerHasToy() and even C_ToyBox.IsToyUsable() only work after TOYS_UPDATED fires a bunch of times.

