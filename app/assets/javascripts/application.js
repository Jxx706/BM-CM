// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require_tree .
//

function generateFields() {
	$("select").prop("disabled", true);
	var value = $("select option:selected").val();
	var new_fields = "";
	var submit_button = '<input type="submit" value="Crear instalador" class="btn btn-large btn-success" name="commit" />';
	for(var i = 2; i <= value; i++) {
		new_fields += "<label>IP del nodo " + i + ":\n";
		new_fields += '<input type="text" name="installer[node' + i + ']" placeholder="Ejemplo: 191.76.31.217" value="" />';
	}
	$("select").after(new_fields);

	$("#button-gen").after(submit_button).remove();
}