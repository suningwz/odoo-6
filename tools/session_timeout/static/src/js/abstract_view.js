odoo.define('session_timeout.abstract_view', function (require) {
"use strict";

    var AbstractView = require('web.AbstractView');

    let intervalList = [];

    AbstractView.include({
        init: function (viewInfo, params) {
            this._super.apply(this, arguments);

            // auto logout after 300 secs if user don't have any activity
                    let idleTimeout = 0;
            $(window).on('mousemove', function(event) {
                idleTimeout = 0;
            })
            $(window).on('keypress', function(event) {
                idleTimeout = 0;
            })

            intervalList.forEach(intervalId => clearInterval(intervalId)); // clear previous interval id of another screen
            intervalList.length = 0 // remove all intervalId in list

            let intervalId = setInterval(() => {
                idleTimeout += 1;
                if (idleTimeout > 300) { // logout after 300 secs
                    $.get('/web/session/logout'); // execute logout action
                    location.reload()
                }
            }, 1000)
            intervalList.push(intervalId);
        }
    })
});