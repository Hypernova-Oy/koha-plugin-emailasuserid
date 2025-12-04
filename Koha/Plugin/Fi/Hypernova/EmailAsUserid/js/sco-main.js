//Koha::Plugin::Fi::Hypernova::EmailAsUserid/js/sco-main.js
/* Bug 36586 - Self-checkouts will get CSRF errors if left inactive for 8 hours */
/* Interim fix for use in SCOUserJS */
/* ---- Self checkout page reload on idle to avoid CSRF errors ---- */
/* IF STATEMENT: Limit to cardnumber entry screen, though not strictly necessary */
// Reload the sco login screen periodically, because the 'AutoSelfCheckAllowed'-syspref fails to reload a session after syspref 'timeout' (24h)
let kpfheauid_bscom = document.querySelector('body#sco_main.CheckingOut');
if (kpfheauid_bscom) {
  if (kpfheauid_config.sco_refresher) {
    let timeoutMinutes = 20;        /* Time, in minutes, to refresh when no user input. */
    let timeoutConnectivityCheck = 10; /* Time, in seconds, to re-check internet connectivity if it is down */
    let idleTimer = 0;
    let forcedIdleTimer = 0;
    const idleThreshold = timeoutMinutes * 60;
    const forcedIdleThreshold = 60*60; /* Time, in seconds, to refresh regardless of user input */
    const requiredStatusCode = 200;
    console.log("idleTimer set to reload page after "+idleThreshold+" seconds.");

    var refreshSco = () => {
      resetTimer();
      clearInterval(idleInterval);
      $.ajax({
        type: 'GET',
        url: window.location.href,
        timeout: 5000,  // allow this many milisecs for network connect to succeed
        success: function(data, text, jqXHR) {
          if (jqXHR.getResponseHeader("x-force-reload")) {
            location.reload(true);
          } else {
            console.log("SCO: Not reloading. Force reload with X-Force-Reload response header.");
          }
          console.log();
          if (jqXHR.status === requiredStatusCode) {
            if ($('input[name="csrf_token"]', data).length) {
              let new_csrf_token = $('input[name="csrf_token"]', data).val();
              console.log("SCO: Fetched new CSRF token " + new_csrf_token);
              $('input[name="csrf_token"]').val(new_csrf_token);
              idleInterval = setInterval(idleUpdate, 1000);
            } else {
              if ($('body#sco_main', data).length) {
                console.log("SCO: Received HTML with body#sco_main, but no csrf_token input element found. Reloading page.");
                location.reload(true);        /* Reload page to refresh CSRF token */
              } else {
                console.log("SCO: refreshSco(), reattempting. Could not find body#sco_main");
                window.setTimeout(refreshSco, (timeoutConnectivityCheck*1000)) ;
              }
            }
          } else {
            console.log("SCO: refreshSco(), reattempting. Status code is not " + requiredStatusCode);
            window.setTimeout(refreshSco, (timeoutConnectivityCheck*1000)) ;
          }
        },
        error: function(XMLHttpRequest, textStatus, errorThrown) {
          // no connection, try again after waitTime
          console.log(XMLHttpRequest);
          console.log(textStatus);
          console.log(errorThrown);
          console.log("SCO: refreshSco(), reattempting. AJAX error.");
          window.setTimeout(refreshSco, (timeoutConnectivityCheck*1000)) ;
        }
        });
    };
    var resetTimer = () => { idleTimer = 0; if (forcedIdleTimer >= forcedIdleThreshold) { forcedIdleTimer = 0; } };
    var idleUpdate = () => {
      idleTimer++;
      forcedIdleTimer++;
      console.log("SCO: Idle timer: " + idleTimer + ", forced timer is: " + forcedIdleTimer);
      if (idleTimer >= idleThreshold || forcedIdleTimer >= forcedIdleThreshold) {
        refreshSco();
      }
    };

    let idleInterval = setInterval(idleUpdate, 1000);

    /* Check for standard user input events (no reload when interaction is occuring) */
    for (var e of ["mousemove","keypress","mousedown","touchstart","scroll"]) {
      document.addEventListener(e, resetTimer);
    }
    resetTimer();
  }
}
