# Tests for Campus Mobile

This documentation provides a brief overview of how we write and run tests for Campus Mobile. We've chosen to adopt Facebook's [Jest](https://facebook.github.io/jest/) and Airbnb's [Enzyme](http://airbnb.io/enzyme/) as our main testing mechanisms.

## Running Tests

To run a test, simple run the following command (assuming the node modules specified in `package.json` have already been installed using `npm install`):
		
	npm test

Jest will report which Test Suites and Tests ran and whether or not they were successful.

## UI / Component Tests

We've adopted Snapshot Testing to help facilitate our UI testing. In essence, a working "snapshot" of Campus Mobile is preserved, and when tests are run, the application is temporarily rendered and then checked against the pre-existing snapshots. If they differ, the test is considered to have failed.

If this happens, either the codebase was updated and the app is supposed to render differently or there's a bug and something isn't rendering correctly.

If the failing test isn't the result of a bug, snapshots can be updated by running the following command:

	npm test -- -u

Tests that aren't snapshot specific can also be written and will be run concurrently with snapshot tests if any are specified.

### Writing UI Tests

#### Placement of Tests

Tests are named after the component that they are testing. The test for `Home.js` is named `Home.test.js`.

We've mirrored the structure of our `__tests__` directory to that of our `app/views/` directory. For example, `/app/views/Home.js` is tested at `__tests/views/Home.test.js`.

The `__snapshots__` folder is created automatically following the creation and first run of a test. These files should be checked in and committed.

#### Structure of Tests

An example test for a UI component is provided for convenience [here.](Example.test.js.example)

If the component that is being testing is wrapped by a `connect()` statement, it is currently dependent on Redux for its props. In order to be able to provide them manually, make that wrapped component the *default* export, and *also* export the unwrapped component. For an example of this, see `app/views/Home.js`.

Sometimes it's useful to mock the initial state of a component, especially if it was originally wrapped with a `connect()`. Populate the `initialState` object with the props the component that is being tested, or else the test will not run successfully. Different states can be passed to the `setup()` function to test other component states.

For further information on writing tests using Jest and Enzyme to write tests, please visit their corresponding websites for their documentation. Links to their websites can be found at the beginning of this README.

Additionally, refer to our other tests for specific examples of how tests are written in the context of Campus Mobile.

### Special Considerations

#### `tests.setup.js`

This is a configuration file that is located at the root of our project. [Sometimes, it's necessary to mock certain native components that won't function correctly under a virtual testing environment.](https://facebook.github.io/jest/docs/en/tutorial-react-native.html#mock-native-modules-using-jestmock) This file is the place to mock native modules that may be interfering with tests running correctly.
