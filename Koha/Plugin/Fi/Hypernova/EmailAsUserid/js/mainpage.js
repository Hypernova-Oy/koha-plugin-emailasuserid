//Koha::Plugin::Fi::Hypernova::EmailAsUserid/js/mainpage.js

if (kpfheauid_config.pending_self_registrations_categorycode) {
  $(document).ready(function() {
    if ($("body#main_intranet-main").length) {
      $.ajax({
        url: '/api/v1/patrons?_page=1&_per_page=20&q={"-and":[[{"me.category_id":"'+kpfheauid_config.pending_self_registrations_categorycode+'"}]]}&_match=contains&_order_by=+me.surname,+me.preferred_name,+me.firstname,+me.middle_name,+me.othernames,+me.street_number,+me.address,+me.address2,+me.city,+me.state,+me.postal_code,+me.country'
      }).done(function(data) {
        $("div#patron_updates_pending").after(`<div class="pending-info" id="patron_self_registrations_pending">
  <a href="/cgi-bin/koha/members/members-home.pl">Self-registrations (search with patron category '${kpfheauid_config.pending_self_registrations_categorycode}')</a>:
  <span class="pending-number-link">`+data.length+`</span>
  </div>
        `);
      });
    }
  });
}