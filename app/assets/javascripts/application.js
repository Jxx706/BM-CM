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


/* Installer functions */
function generateFields() {
	disable("select");
	var value = $("select option:selected").val();
	var new_fields = "";
	var submit_button = '<input type="submit" value="Crear instalador" class="btn btn-large btn-success" name="commit" />';
	for(var i = 2; i <= value; i++) {
		new_fields += "<label>IP del nodo " + i + ":\n";
		new_fields += '<input type="text" name="installer[node' + i + ']" placeholder="Ejemplo: 191.76.31.217" value="" />';
	}
	$("select").after(new_fields); //Insert new fields

	$("#button-gen").after(submit_button).remove(); //Replace with "Submit" button.
}

function disable(selector) {
	$(selector).prop("disabled", true);
}

/* flows/new */
function hideOrShow(self) {

	switch(self.id) {
		case "radio_option1":
			$("#select_tool").show();
			$("#select_maintenance").hide();
			//$("select_???").hide();
			break;
		case "radio_option2":
			$("#select_tool").hide();
			$("#select_maintenance").show();
			//$("select_???").hide();
			break;
		case "radio_option3":
			$("#select_tool").hide();
			$("#select_maintenance").hide();
			//$("select_???").show();
			break;
	}
}


function nextStep(self, next_id) {
	$(self).remove();
	$("#" + next_id).fadeIn();
}

function changeIfChecked(self) { 
	if (document.getElementById(self.id).checked) { 
		$(self).val("yes"); 
	} else {
		$(self).val("no"); 	
	}
}

function toggleValue(elementId, val1, val2) {
	var selector = $("#" + elementId) 
	if (selector.val() == val1) {
		selector.val(val2);
	} else {
		selector.val(val1);
	}
}

function switchConfigTool(text_id, field_id) {
	var text = $(text_id);
	var field = $(field_id);

	if (field.val() == "yes") {
		field.val("no")
	} else {
		field.val("yes")
	};

	if (text.hasClass("text-error")) {
		text.removeClass("text-error");
		text.addClass("text-success");
		text.text("Configurar");
	} else {
		text.removeClass("text-success");
		text.addClass("text-error");
		text.text("No configurar (eliminar configuracion)");
	}

}