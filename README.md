# Restaurant Waitlist App

A simple mobile application for restaurant staff to manage the entry waitlist on a phone.

## How to Run the App on an Emulator

1. Open an Android emulator or iOS simulator on your machine.
2. Clone this repository and navigate into the project directory:
   ```bash
   git clone <YOUR_GITHUB_REPOSITORY_LINK>
   cd restaurant_waitlist_app_aghar

Technology & Data Storage Choice
I chose Flutter because it allows fast cross-platform mobile development with
simple state management and UI built-in. 
For data storage, I used SharedPreferences as a lightweight on-device storage solution 
to easily persist the JSON-serialized waitlist and incremental ticket counter across app 
restarts without database boilerplate.


Requirements Coverage
Complete:

Staff can add a party by entering a name and party size with strict form validation (Name cannot be empty; Party size must be a whole number > 0).

Automatically assigns unique, strictly incrementing ticket numbers that are never reused after removal.

Waitlist view displays parties in order, showing exact "parties ahead" (count of waiting parties before them) for each party.

Staff can remove any party from the list, updating the UI immediately.

Complete data persistence across app restarts using local device storage.

Incomplete / Optional Extras:

Optional extras (party details editing, undoing removals, history screen, and estimated wait times) were
deliberately omitted to focus entirely on core criteria quality and correctness.