(function ($) {
	$.extend($.tree.plugins, {
		"dragndropctxmenu" : {
			object : $("<ul id='jstree-dragndropctxmenu' class='tree-context' />"),
			data : {
				t : false,
				a : false,
				r : false
			},

			defaults : {
				class_name : "hover",
				items : {
					create : {
						label	: "Copy", 
						icon	: "create",
                        action	: function (NODE, TREE_OBJ) { alert("Copy"); },
					},
					rename : {
						label	: "Move", 
						icon	: "rename",
                        action	: function (NODE, TREE_OBJ) { alert("Move"); },
					},
					remove : {
						label	: "Link",
						icon	: "remove",
                        action	: function (NODE, TREE_OBJ) { alert("Link"); },
					}
				}
			},
			show : function(obj, t) {
				var opts = $.extend(true, {}, $.tree.plugins.dragndropctxmenu.defaults, t.settings.plugins.dragndropctxmenu);
				obj = $(obj);
				$.tree.plugins.dragndropctxmenu.object.empty();
				var str = "";
				var cnt = 0;
				for(var i in opts.items) {
					if(!opts.items.hasOwnProperty(i)) continue;
					if(opts.items[i] === false) continue;
					var r = 1;
					if(typeof opts.items[i].visible == "function") r = opts.items[i].visible.call(null, $.tree.plugins.dragndropctxmenu.data.a, t);
					if(r == -1) continue;
					else cnt ++;
					if(opts.items[i].separator_before === true) str += "<li class='separator'><span>&nbsp;</span></li>";
					str += '<li><a href="#" rel="' + i + '" class="' + i + ' ' + (r == 0 ? 'disabled' : '') + '">';
					if(opts.items[i].icon) str += "<ins " + (opts.items[i].icon.indexOf("/") == -1 ? " class='" + opts.items[i].icon + "' " : " style='background-image:url(\"" + opts.items[i].icon + "\");' " ) + ">&nbsp;</ins>";
					else str += "<ins>&nbsp;</ins>";
					str += "<span>" + opts.items[i].label + '</span></a></li>';
					if(opts.items[i].separator_after === true) str += "<li class='separator'><span>&nbsp;</span></li>";
				}
				var tmp = obj.children("a:visible").offset();
				$.tree.plugins.dragndropctxmenu.object.attr("class","tree-context tree-" + t.settings.ui.theme_name.toString() + "-context").html(str);
				var h = $.tree.plugins.dragndropctxmenu.object.height();
				var w = $.tree.plugins.dragndropctxmenu.object.width();
				var x = tmp.left;
				var y = tmp.top + parseInt(obj.children("a:visible").height()) + 2;
				var max_y = $(window).height() + $(window).scrollTop();
				var max_x = $(window).width() + $(window).scrollLeft();
				if(y + h > max_y) y = Math.max( (max_y - h - 2), 0);
				if(x + w > max_x) x = Math.max( (max_x - w - 2), 0);
				$.tree.plugins.dragndropctxmenu.object.css({ "left" : (x), "top" : (y) }).fadeIn("fast");
			},
			hide : function () {
				if(!$.tree.plugins.dragndropctxmenu.data.t) return;
				var opts = $.extend(true, {}, $.tree.plugins.dragndropctxmenu.defaults, $.tree.plugins.dragndropctxmenu.data.t.settings.plugins.dragndropctxmenu);
				if($.tree.plugins.dragndropctxmenu.data.r && $.tree.plugins.dragndropctxmenu.data.a) {
					$.tree.plugins.dragndropctxmenu.data.a.children("a, span").removeClass(opts.class_name);
				}
				$.tree.plugins.dragndropctxmenu.data = { a : false, r : false, t : false };
				$.tree.plugins.dragndropctxmenu.object.fadeOut("fast");
			},
			exec : function (cmd) {
				if($.tree.plugins.dragndropctxmenu.data.t == false) return;
				var opts = $.extend(true, {}, $.tree.plugins.dragndropctxmenu.defaults, $.tree.plugins.dragndropctxmenu.data.t.settings.plugins.dragndropctxmenu);
				try { opts.items[cmd].action.apply(null, [$.tree.plugins.dragndropctxmenu.data.a, $.tree.plugins.dragndropctxmenu.data.t]); } catch(e) { };
			},

			callbacks : {
				oninit : function () {
					if(!$.tree.plugins.dragndropctxmenu.css) {
						var css = '#jstree-dragndropctxmenu { display:none; position:absolute; z-index:2000; list-style-type:none; margin:0; padding:0; left:-2000px; top:-2000px; } .tree-context { margin:20px; padding:0; width:180px; border:1px solid #979797; padding:2px; background:#f5f5f5; list-style-type:none; }.tree-context li { height:22px; margin:0 0 0 27px; padding:0; background:#ffffff; border-left:1px solid #e0e0e0; }.tree-context li a { position:relative; display:block; height:22px; line-height:22px; margin:0 0 0 -28px; text-decoration:none; color:black; padding:0; }.tree-context li a ins { text-decoration:none; float:left; width:16px; height:16px; margin:0 0 0 0; background-color:#f0f0f0; border:1px solid #f0f0f0; border-width:3px 5px 3px 6px; line-height:16px; }.tree-context li a span { display:block; background:#f0f0f0; margin:0 0 0 29px; padding-left:5px; }.tree-context li.separator { background:#f0f0f0; height:2px; line-height:2px; font-size:1px; border:0; margin:0; padding:0; }.tree-context li.separator span { display:block; margin:0px 0 0px 27px; height:1px; border-top:1px solid #e0e0e0; border-left:1px solid #e0e0e0; line-height:1px; font-size:1px; background:white; }.tree-context li a:hover { border:1px solid #d8f0fa; height:20px; line-height:20px; }.tree-context li a:hover span { background:#e7f4f9; margin-left:28px; }.tree-context li a:hover ins { background-color:#e7f4f9; border-color:#e7f4f9; border-width:2px 5px 2px 5px; }.tree-context li a.disabled { color:gray; }.tree-context li a.disabled ins { }.tree-context li a.disabled:hover { border:0; height:22px; line-height:22px; }.tree-context li a.disabled:hover span { background:#f0f0f0; margin-left:29px; }.tree-context li a.disabled:hover ins { border-color:#f0f0f0; background-color:#f0f0f0; border-width:3px 5px 3px 6px; }';
						$.tree.plugins.dragndropctxmenu.css = this.add_sheet({ str : css });
					}
				},
                    //onrgtclk : function (n, t, e) {},
                    onmove : function (n, rn, ty, t, rb) {
					var opts = $.extend(true, {}, $.tree.plugins.dragndropctxmenu.defaults, t.settings.plugins.dragndropctxmenu);
					n = $(n);
					if(n.size() == 0) return;
					$.tree.plugins.dragndropctxmenu.data.t = t;
					if(!n.children("a:eq(0)").hasClass("clicked")) {
						$.tree.plugins.dragndropctxmenu.data.a = n;
						$.tree.plugins.dragndropctxmenu.data.r = true;
						n.children("a").addClass(opts.class_name);
						//e.target.blur();
					}
					else { 
						$.tree.plugins.dragndropctxmenu.data.r = false; 
						$.tree.plugins.dragndropctxmenu.data.a = (t.selected_arr && t.selected_arr.length > 1) ? t.selected_arr : t.selected;
					}
					$.tree.plugins.dragndropctxmenu.show(n, t);
					//e.preventDefault(); 
					//e.stopPropagation();
					// return false; // commented out because you might want to do something in your own callback
				},
				onchange : function () { $.tree.plugins.dragndropctxmenu.hide(); },
				beforedata : function () { $.tree.plugins.dragndropctxmenu.hide(); },
				ondestroy : function () { $.tree.plugins.dragndropctxmenu.hide(); }
			}
		}
	});
	$(function () {
		$.tree.plugins.dragndropctxmenu.object.hide().appendTo("body");
		$("a", $.tree.plugins.dragndropctxmenu.object[0])
			.live("click", function (event) {
				if(!$(this).hasClass("disabled")) {
					$.tree.plugins.dragndropctxmenu.exec.apply(null, [$(this).attr("rel")]);
					$.tree.plugins.dragndropctxmenu.hide();
				}
				event.stopPropagation();
				event.preventDefault();
				return false;
			})
		$(document).bind("mousedown", function(event) { if($(event.target).parents("#jstree-dragndropctxmenu").size() == 0) $.tree.plugins.dragndropctxmenu.hide(); });
	});
})(jQuery);