 $(function()

    {

       $("#demo1").click(function() {
                   		    $.prompt("你好，卡哥!",{title: "提示"});
                   	                }); //样式一  

       $("#demo2").click(function() {
                   		    $.prompt("i want you ", {
	                                 title: "do you want massage?",
	                                 buttons: { "确定": true, "取消": false },
                                   submit:function(e,v,m,f){}//v表示用户点击值 true or false (e.preventDefault())
                                    });
                   	             });//样式二     

       $("#demo3").click(function() {
                   		  var s= $.prompt("确定要撤销订单吗？",{
	                                           title: "撤销订单",
	                                         buttons: { "是": true, "否": false },
	                                          submit:function(e,v,m,f)
                                                    { 
		                                           if (v) 
                                                              {$("#demo1").css("display","none")}
                                                       else 
                                                             {$("#demo1").css("display","block")}
                                                    }
                                     });
                   	      });//样式三  

         $("#demo4").click(function() 
                        {
                              var num="5";
                                var s= $.prompt("确定要支付吗？",
                                {
                                                picture:"worning.png",//此处为本地封装后，将要在对话框中显示的图片相对于Html页面的相对或绝对路径，图片尺寸以春阳提供的黄色叹号为准
                                                 title: "支付订单",
                                               buttons: { "是": true, "否": false },
                                                submit:function(e,v,m,f)
                                                    { // v表示用户点击值 true or false (e.preventDefault())
                                                       if (v) 
                                                  {
                                                                  $.prompt("<input type='radio' class=''>条目一<br><input type='radio'>条目二",
                                                                        {
                                                                          buttons: { "确定": true, "取消": false },
                                                                              title:"选择装箱地址：<label class='labelClass'>已保存了"+num+"条地址,还能保存"+num+"条地址</label>",
                                                                              submit:function(e,v,m,f) {
                                                                               
                                                                              }
                                                                        });
                                                  }
                                                       else 
                                                  {
                                                                  $("#demo1").css("display","block")
                                                  }
                                 }
                        });
                              });//样式四 

           $("#demo5").click(function() 
                        {
                              var num="5";
                                var s= $.prompt("支付失败。",
                                {
                                                picture:"fail.png",//此处为本地封装后，将要在对话框中显示的图片相对于Html页面的相对或绝对路径，图片尺寸以春阳提供的黄色叹号为准
                                                 title: "支付订单",
                                               buttons: { "继续操作": true, "取消": false },
                                                submit:function(e,v,m,f)
                                                    { // v表示用户点击值 true or false (e.preventDefault())
                                                       if (v) 
                                                  {
                                                                  $.prompt("是是是",
                                                                        {
                
                                                                          buttons: { "确定": true, "取消": false },
                                                                              title:"选择装箱地址：<label class='labelClass'>已保存了"+num+"条地址,还能保存"+num+"条地址</label>",
                                                                             
                                                                              submit:function(e,v,m,f) {
                                                                               
                                                                              }
                                                                        });
                                                  }
                                                       else 
                                                  {
                                                                  $("#demo1").css("display","block")
                                                  }
                                 }
                        });
                              });//样式四  

       })