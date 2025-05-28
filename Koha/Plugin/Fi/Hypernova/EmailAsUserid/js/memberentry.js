//Koha::Plugin::Fi::Hypernova::EmailAsUserid/js/memberentry.js

$(document).ready(function() {
  if ($("body#pat_memberentrygen").length) {
    // primary email to username
    let useridElement = document.querySelector('#memberentry_userid input#userid');
    let emailElement = document.querySelector('#memberentry_contact input#email');
    useridElement.setAttribute("disabled", "disabled");
    useridElement.value = emailElement.value;
    emailElement.addEventListener("change", (function(event) {
      useridElement.value = event.target.value;
    }));
  }
});
