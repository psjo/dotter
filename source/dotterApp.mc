using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class dotterApp extends App.AppBase {

    var view;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        view = new dotterView();
        return [ view ];
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() {
        view.load = true;
        Ui.requestUpdate();
    }

}