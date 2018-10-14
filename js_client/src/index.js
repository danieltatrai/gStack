import React from "react";
import ReactDOM from "react-dom";
import "./index.css";
import App from "./App";
import { WebSocketBridge } from 'django-channels'

const webSocketBridge = new WebSocketBridge();
webSocketBridge.connect('wss://' + window.location.host +'/ws/');
webSocketBridge.listen(function(action, stream) {
  console.log(action, stream);
});

// import registerServiceWorker from './registerServiceWorker';

ReactDOM.render(<App />, document.getElementById("root"));
// registerServiceWorker();
