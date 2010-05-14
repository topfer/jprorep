(function ($) {
	$.extend($.tree.plugins, {
		"arcorectxmenu" : {
			object : $("<ul id='jstree-arcorectxmenu' class='tree-context' />"),
			data : {
				TREE_OBJ : false,
				NODE : false,
				r : false
			},
			defaults : {
				class_name : "hover",
				items_rgtclick : {
					create : {
						label	: "Create", 
						icon	: "create",
                        visible : function  (NODE, TREE_OBJ) {
                            if ( $(NODE).attr("class").search(/object/i) == -1 )
                                return 1;
                            else
                                return 0;
                        },                          
                        action	: function (NODE, TREE_OBJ) { 
                            var ndForm = top.details.document.forms.nodeForm;
                            ndForm.action = "details.pl";
                            ndForm.elements.nodeDN.value=$(NODE).attr("id");
                            ndForm.elements.predicate.value = "create";
                            ndForm.submit();
                            top.currentJSTree = TREE_OBJ;
                            top.currentJSTreeNode = NODE;
                            return false;
                        },
                        separator_after : true
					},
					edit : {
						label	: "Edit", 
						icon	: "edit",
                        action	: function (NODE, TREE_OBJ) { 
                            var ndForm = top.details.document.forms.nodeForm;
                            ndForm.action = "details.pl";
                            ndForm.elements.nodeDN.value=$(NODE).attr("id");
                            ndForm.elements.predicate.value = "edit";
                            ndForm.submit();
                            return false;
                        },
                        separator_after : true
					},
					copy : {
						label	: "Copy", 
						icon	: "copy",
                        action	: function (NODE, TREE_OBJ) { alert("Copy"); }
					},
					cut : {
						label	: "Cut", 
						icon	: "cut",
                        action	: function (NODE, TREE_OBJ) { alert("Cut"); }
					},
					paste : {
						label	: "Paste", 
						icon	: "paste",
                        action	: function (NODE, TREE_OBJ) { alert("Paste"); }
					},
					link : {
						label	: "Link", 
						icon	: "link",
                        action	: function (NODE, TREE_OBJ) { alert("Link"); },
                        separator_after : true
					},
					remove : {
						label	: "Remove",
						icon	: "remove",
                        action	: function (NODE, TREE_OBJ) { 
                            var ndForm = top.details.document.forms.nodeForm;
                            ndForm.action = "update.pl";
                            ndForm.elements.nodeDN.value=$(NODE).attr("id");
                            ndForm.elements.predicate.value = "delete";
                            ndForm.submit();
                            $.each(NODE, function () { TREE_OBJ.remove(this); });
                        }
					}
				},
				items_dragndrop : {
					copy : {
						label	: "Copy", 
						icon	: "copy",
                        action	: function (NODE, TREE_OBJ) { alert("Copy"); }
					},
					move : {
						label	: "Move", 
						icon	: "move",
                        action	: function (NODE, TREE_OBJ) { alert("Move"); }
					},
					link : {
						label	: "Link", 
						icon	: "link",
                        action	: function (NODE, TREE_OBJ) { alert("Link"); }
					}
				}                   
			},
			show : function(NODE, TREE_OBJ) {
				var opts = $.extend(true, {}, $.tree.plugins.arcorectxmenu.defaults, TREE_OBJ.settings.plugins.arcorectxmenu);
				NODE = $(NODE);
				$.tree.plugins.arcorectxmenu.object.empty();
				var str = "";
				var cnt = 0;
				for(var i in opts.items) {
					if(!opts.items.hasOwnProperty(i)) continue;
					if(opts.items[i] === false) continue;
					var r = 1;
					if(typeof opts.items[i].visible == "function") r = opts.items[i].visible.call(null, $.tree.plugins.arcorectxmenu.data.NODE, TREE_OBJ);
					if(r == -1) continue;
					else cnt ++;
					if(opts.items[i].separator_before === true) str += "<li class='separator'><span>&nbsp;</span></li>";
					str += '<li><a href="#" rel="' + i + '" class="' + i + ' ' + (r == 0 ? 'disabled' : '') + '">';
					if(opts.items[i].icon) str += "<ins " + (opts.items[i].icon.indexOf("/") == -1 ? " class='" + opts.items[i].icon + "' " : " style='background-image:url(\"" + opts.items[i].icon + "\");' " ) + ">&nbsp;</ins>";
					else str += "<ins>&nbsp;</ins>";
					str += "<span>" + opts.items[i].label + '</span></a></li>';
					if(opts.items[i].separator_after === true) str += "<li class='separator'><span>&nbsp;</span></li>";
				}
				var tmp = NODE.children("a:visible").offset();
				$.tree.plugins.arcorectxmenu.object.attr("class","tree-context tree-" + TREE_OBJ.settings.ui.theme_name.toString() + "-context").html(str);
				var h = $.tree.plugins.arcorectxmenu.object.height();
				var w = $.tree.plugins.arcorectxmenu.object.width();
				var x = tmp.left;
				var y = tmp.top + parseInt(NODE.children("a:visible").height()) + 2;
				var max_y = $(window).height() + $(window).scrollTop();
				var max_x = $(window).width() + $(window).scrollLeft();
				if(y + h > max_y) y = Math.max( (max_y - h - 2), 0);
				if(x + w > max_x) x = Math.max( (max_x - w - 2), 0);
				$.tree.plugins.arcorectxmenu.object.css({ "left" : (x), "top" : (y) }).fadeIn("fast");
			},
			hide : function () {
				if(!$.tree.plugins.arcorectxmenu.data.TREE_OBJ) return;
				var opts = $.extend(true, {}, $.tree.plugins.arcorectxmenu.defaults, $.tree.plugins.arcorectxmenu.data.TREE_OBJ.settings.plugins.arcorectxmenu);
				if($.tree.plugins.arcorectxmenu.data.r && $.tree.plugins.arcorectxmenu.data.NODE) {
					$.tree.plugins.arcorectxmenu.data.NODE.children("a, span").removeClass(opts.class_name);
				}
				$.tree.plugins.arcorectxmenu.data = { a : false, r : false, t : false };
				$.tree.plugins.arcorectxmenu.object.fadeOut("fast");
			},
			exec : function (cmd) {
				if($.tree.plugins.arcorectxmenu.data.TREE_OBJ == false) return;
				var opts = $.extend(true, {}, $.tree.plugins.arcorectxmenu.defaults, $.tree.plugins.arcorectxmenu.data.TREE_OBJ.settings.plugins.arcorectxmenu);
				try { opts.items[cmd].action.apply(null, [$.tree.plugins.arcorectxmenu.data.NODE, $.tree.plugins.arcorectxmenu.data.TREE_OBJ]); } catch(e) { };
			},
			callbacks : {
// 				oninit : function () {
// 					if(!$.tree.plugins.arcorectxmenu.css) {
// 						var css = '#jstree-arcorectxmenu { display:none; position:absolute; z-index:2000; list-style-type:none; margin:0; padding:0; left:-2000px; top:-2000px; } .tree-context { margin:20px; padding:0; width:180px; border:1px solid #979797; padding:2px; background:#f5f5f5; list-style-type:none; }.tree-context li { height:22px; margin:0 0 0 27px; padding:0; background:#ffffff; border-left:1px solid #e0e0e0; }.tree-context li a { position:relative; display:block; height:22px; line-height:22px; margin:0 0 0 -28px; text-decoration:none; color:black; padding:0; }.tree-context li a ins { text-decoration:none; float:left; width:16px; height:16px; margin:0 0 0 0; background-color:#f0f0f0; border:1px solid #f0f0f0; border-width:3px 5px 3px 6px; line-height:16px; }.tree-context li a span { display:block; background:#f0f0f0; margin:0 0 0 29px; padding-left:5px; }.tree-context li.separator { background:#f0f0f0; height:2px; line-height:2px; font-size:1px; border:0; margin:0; padding:0; }.tree-context li.separator span { display:block; margin:0px 0 0px 27px; height:1px; border-top:1px solid #e0e0e0; border-left:1px solid #e0e0e0; line-height:1px; font-size:1px; background:white; }.tree-context li a:hover { border:1px solid #d8f0fa; height:20px; line-height:20px; }.tree-context li a:hover span { background:#e7f4f9; margin-left:28px; }.tree-context li a:hover ins { background-color:#e7f4f9; border-color:#e7f4f9; border-width:2px 5px 2px 5px; }.tree-context li a.disabled { color:gray; }.tree-context li a.disabled ins { }.tree-context li a.disabled:hover { border:0; height:22px; line-height:22px; }.tree-context li a.disabled:hover span { background:#f0f0f0; margin-left:29px; }.tree-context li a.disabled:hover ins { border-color:#f0f0f0; background-color:#f0f0f0; border-width:3px 5px 3px 6px; }';
// 						$.tree.plugins.arcorectxmenu.css = this.add_sheet({ str : css });
// 					}
// 				},
                onselect : function(NODE,TREE_OBJ) { 
                    var ndForm = top.details.document.forms.nodeForm;
                    ndForm.elements.nodeDN.value=$(NODE).attr("id");
                    if ( ndForm.elements.tab.value == "keylist" ) {
                        top.exportRequest('html');
                    } else {
                        ndForm.action = ndForm.elements.tab.value + ".pl"; 
                        ndForm.elements.predicate.value = "view";                                  
                        ndForm.submit();
                    }
                },
				onrgtclk : function (NODE, TREE_OBJ, EV) {
					var opts = $.extend(true, {}, $.tree.plugins.arcorectxmenu.defaults, TREE_OBJ.settings.plugins.arcorectxmenu);
					NODE = $(NODE);
					if(NODE.size() == 0) return;
					$.tree.plugins.arcorectxmenu.data.TREE_OBJ = TREE_OBJ;
					if(!NODE.children("a:eq(0)").hasClass("clicked")) {
						$.tree.plugins.arcorectxmenu.data.NODE = NODE;
						$.tree.plugins.arcorectxmenu.data.r = true;
						NODE.children("a").addClass(opts.class_name);
						e.target.blur();
					}
					else { 
						$.tree.plugins.arcorectxmenu.data.r = false; 
						$.tree.plugins.arcorectxmenu.data.NODE = (TREE_OBJ.selected_arr && TREE_OBJ.selected_arr.length > 1) ? TREE_OBJ.selected_arr : TREE_OBJ.selected;
					}
                    $.tree.plugins.arcorectxmenu.defaults.items = $.tree.plugins.arcorectxmenu.defaults.items_rgtclick;
					$.tree.plugins.arcorectxmenu.show(NODE, TREE_OBJ);
					EV.preventDefault(); 
					EV.stopPropagation();
					// return false; // commented out because you might want to do something in your own callback
				},
                onmove : function(NODE,REF_NODE,TYPE,TREE_OBJ,RB) { 
					var opts = $.extend(true, {}, $.tree.plugins.arcorectxmenu.defaults, TREE_OBJ.settings.plugins.arcorectxmenu);
					NODE = $(NODE);
					if(NODE.size() == 0) return;
					$.tree.plugins.arcorectxmenu.data.TREE_OBJ = TREE_OBJ;
					if(!NODE.children("a:eq(0)").hasClass("clicked")) {
						$.tree.plugins.arcorectxmenu.data.NODE = NODE;
						$.tree.plugins.arcorectxmenu.data.r = true;
						NODE.children("a").addClass(opts.class_name);
					}
					else { 
						$.tree.plugins.arcorectxmenu.data.r = false; 
						$.tree.plugins.arcorectxmenu.data.NODE = (TREE_OBJ.selected_arr && TREE_OBJ.selected_arr.length > 1) ? TREE_OBJ.selected_arr : TREE_OBJ.selected;
					}

                    $.tree.plugins.arcorectxmenu.defaults.items = $.tree.plugins.arcorectxmenu.defaults.items_dragndrop;
					$.tree.plugins.arcorectxmenu.show(NODE, TREE_OBJ);
                },
				onchange : function () { $.tree.plugins.arcorectxmenu.hide(); },
				beforedata : function () { $.tree.plugins.arcorectxmenu.hide(); },
				ondestroy : function () { $.tree.plugins.arcorectxmenu.hide(); }
			}
		}
	});
	$(function () {
		$.tree.plugins.arcorectxmenu.object.hide().appendTo("body");
		$("a", $.tree.plugins.arcorectxmenu.object[0])
			.live("click", function (event) {
				if(!$(this).hasClass("disabled")) {
					$.tree.plugins.arcorectxmenu.exec.apply(null, [$(this).attr("rel")]);
					$.tree.plugins.arcorectxmenu.hide();
				}
				event.stopPropagation();
				event.preventDefault();
				return false;
			})
		$(document).bind("mousedown", function(event) { if($(event.target).parents("#jstree-arcorectxmenu").size() == 0) $.tree.plugins.arcorectxmenu.hide(); });
	});
})(jQuery);
