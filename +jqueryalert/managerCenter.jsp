<!DOCTYPE html>
<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@ page language="java" import="com.icargo.entiy.UserSession"%>
<%@ page language="java" import="com.icargo.web.sso.SessionUtils"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>

<%
	String path = request.getContextPath();
	String basePath = request.getScheme() + "://"
			+ request.getServerName() + ":" + request.getServerPort()
			+ path + "/";
		
	UserSession user = SessionUtils.getUser(request);
	String userName = "";
	String userQQ = "";
	String userPhone = "";
	String realName = "";
	String userId = "";

	String masterUserId = "";
	String slaveUserId = "";
	
	if ( user != null ){
		
		String role = "";
		if(user != null){
			realName = user.getRealName() == null ? "" : user.getRealName();
			
			role = user.getRole();
			
			userName = user.getUserName();
			userQQ = user.getQq() == null ? "" : user.getQq();
			userPhone = user.getPhone() == null ? "" : user.getPhone();
			userId = user.getUserId().toString();

			if(user.getRoleId() == 3){
				masterUserId = user.getUserId().toString();

			} else if (user.getRoleId() == 4){
				masterUserId = user.getMasterUserId().toString();
				slaveUserId = user.getUserId().toString();
			}	
		}
	}
%>

<head>
    <!-- 屏幕自适应 -->
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="keywords" content="卡哥 卡哥科技 卡哥平台 卡哥客服 卡哥电话 卡哥注册 线上拖卡平台 外贸拖卡  港口集装箱O2O 集卡运输滴滴打车" />
    <meta name="description" content="卡哥信息科技有限公司是一家致力于通过互联网和移动互联网打造的O2O物流信息服务平台；通过科技信息的手段来优化中国集卡的公路物流运输，提升中国物流行业的整体效率。" />
	<title>卡哥科技</title>
	<!--[if lt IE 9]>
    <script type="text/javascript" charset="utf-8" src="<%= basePath%>freight/js/json2.js"></script>
	<![endif]-->
	<link rel="stylesheet" type="text/css" href="<%= basePath%>freight/css/managerCenter.css"/>
	<link rel="stylesheet" type="text/css" href="<%= basePath%>freight/css/order.css"/>
	<jsp:include page="/freight/include.jsp"></jsp:include>
	<jsp:include page="/freight/head.jsp"></jsp:include>
	<script type="text/javascript" charset="utf-8" src="<%= basePath%>freight/js/cargo/cargo_order.js"></script>
	<script type="text/javascript" charset="utf-8" src="<%= basePath%>freight/js/cargo/cargo_finance.js"></script>
	<script type="text/javascript" charset="utf-8" src="<%= basePath%>freight/js/cargo/cargo_account.js"></script>
	<style>
		.oni-pager-item{
			border: 1px solid #d4d4d4;
			padding: 0 10px;
			margin-right: 5px;
			font-size: 12px;
			border-radius: 2px;
			cursor: pointer;
			display: inline-block;
			line-height: 24px;
		}
	</style>

	<script>
	var query_func = {};
	
	function switchTab(_index){
		resetTabColor();
		var div = "div"+_index;
		document.getElementById(div).style.borderTop="3px solid #01c6b2";
	}
	function resetTabColor(){
		document.getElementById("div1").style.borderTop="0px solid #01c6b2";
		document.getElementById("div2").style.borderTop="0px solid #01c6b2";
	}
	
	var model_ordercenter = {};
	var pagination_rows = 10;
	
	/**
	* 订单付款
	*@param orderId 订单Id
	*/
	function orderPayment(orderId,acc){
		//封装成order对象
		var order = new Object();
		order.id=orderId;
		//封装成数组对象
		var arr = new Array();
		arr.push(order);
		model_ordercenter.payOrderList=arr;
// 		orderPaymentList();
		financeBalanceData("<%= basePath%>/finance/getFinance",
				function(charge, availableCharge,frozeCharge) {
					//获取需要花费的钱
					model_ordercenter.finalPayMoney = acc;
					model_ordercenter.availableCharge=availableCharge;
					if(acc > availableCharge){
						avalon.vmodels["cDialog"].toggle = true;
					}else{
						avalon.vmodels["pDialog"].toggle = true;
					}
					
				});
		

	}
	/**
	* 订单付款
	*@param orders 订单列表
	*/
	function orderPaymentList(){
		var data = new Array();
		var orderList = model_ordercenter.payOrderList;
		for(var i = 0; i < orderList.length; i++){
			data.push({"id" : orderList[i].id});
		}
		var _payOrderList = JSON.stringify(data);
		 $.ajax({
 			url: "<%=basePath%>"+'order/orderPayment',
 			type: 'post',
 			data: {"orderList":_payOrderList},
 			async: false,
 			success:function(_data){
 				if(_data.code==0){
 					alert("付款成功");
 					model_ordercenter.btnClickQuery();
 				}else if(_data.code==-1){
 					alert("系统异常，请稍后重试");
 				}else{
 					alert(_data.msg);
 				}
 			},
 			error:function(){
 				alert("系统异常，请稍后重试！");
 			}
 		});
	}
	
	function toPayOrderList(){
		//获取选中订单的值
		var arrOrder = new Array();
		var $checkBoxList =  $('input:checkbox[name=payOrderIds]:checked');
		if($checkBoxList==null|| $checkBoxList.length==0){
			alert("请选择需要支付的订单");
		}else{
			var totalPrice = 0;
			var price = 0;
			$checkBoxList.each(function(){ 
				var order = new Object();
				var data = $(this).val().split("_");
				order.id=data[0];
				arrOrder.push(order);
				//price = $("#orderPrice" + $(this).val()).html();
				//totalPrice += price;
				if(typeof(data[1]) != "undefined" && typeof(data[1]) != "NaN"){
					totalPrice = totalPrice + parseFloat(data[1]);
				}
				
            });
			model_ordercenter.payOrderList=arrOrder;
			
			financeBalanceData("<%= basePath%>/finance/getFinance",
					function(charge, availableCharge,frozeCharge) {
						//获取需要花费的钱
						model_ordercenter.finalPayMoney = totalPrice.toFixed(2);
						model_ordercenter.availableCharge=availableCharge.toFixed(2);
						if(totalPrice > availableCharge){
							avalon.vmodels["cDialog"].toggle = true;
						}else{
							avalon.vmodels["pDialog"].toggle = true;
						}
						});
			
			//orderPaymentList();
		}
	}
	
	function sel(o){
		var ch = document.getElementsByName("payOrderIds");
		for (var i=0;i<ch.length;i++){
			       ch[i].checked = o.checked;
			    }

	}
	
		require(["dialog/avalon.dialog", "mmRequest/mmRequest", "tooltip/avalon.tooltip","pager/avalon.pager"], function(avalon){
		model_ordercenter = avalon.define({
			$id: "order_region",	//	区域id
			pager:{
				perPages:10,
				totalItems: 0,
				showJumper: true,
				onJump: function(e, data) {
					model_ordercenter.pages = data.currentPage;
					if(model_ordercenter.tp == 1){
						model_ordercenter.orderAllClick();
					}else if(model_ordercenter.tp == 2){
						model_ordercenter.RepayClick();
					}else if(model_ordercenter.tp == 3){
						model_ordercenter.DoingClick();
					}else if(model_ordercenter.tp == 4){
						model_ordercenter.FinishClick();
					}
				}
			},	
			$query_func:{},			
			blno: "",				//	提单号
			userName:"<%= userName%>",
			userId:"<%= userId%>",
			boxtype: "",			//	箱型
			trucker_phone:"",		//	司机手机号：
			starttime:"",			//	开始时间
			endtime:"",				//	结束时间
			factory_phone:"",		//	装箱联系电话
			factory_addr:"",			//	货代名称
			orderList:[],			//	订单列表
			charge:0,				//	余额
			availableCharge:0,		//	可用余额
			frozeCharge:0,			//	冻结资金
			rows:pagination_rows,
			pages:1,
			total_orders:0,
			tp:1,
			$skipArray : ["pager"],
			freightName:"<%= realName%>",
			toolTipsContent:"",
			dialogMessage:"",
			vip:0,
			order_count:0,
			rePayOrder_count:0,
			finish_fee:0,
			availableCharge:"",
			charge_sheet:[],	//	消费明细
			finalPayMoney:"",
			cancelDialogMsg:"",
			payOrderList:[],
			currentSelect:-1,
			$payDialog:{
				showClose:false,
				title : '支付订单',
				confirmName:"支付",
				cancelName:"放弃",
				onConfirm:function(){
					//付款
					orderPaymentList();
				},
				onCancel:function(){
					return;
				}
			
			},
			$chargeDialog:{
				showClose:false,
				title : '支付订单',
				confirmName:"去充值",
				cancelName:"稍后付款",
				onConfirm:function(){
					window.location.href = "<%= basePath%>charge/charge";
				},
				onCancel:function(){
					return;
				}
			
			},
			orderAllClick: function(){
			//	全部状态的订单查询
				cargo_orderlistAll( "<%= basePath%>/order/search"
					, ""
					, ""
					, ""
					, ""
					, ""
					, ""
					, model_ordercenter.pager.perPages	//	每页显示多少条
					, model_ordercenter.pages		//	显示第几页
					, function(bret,msg, data, total_rows ){
						if( bret )
						{
							model_ordercenter.total_orders =  total_rows;	//	取出总的条数，做分页使用
							model_ordercenter.orderList = data;	//	根据返回的值绑定订单列表
							
						}
						else
						{
							alert("订单查询失败:"+ msg );
						}
						
					});
					
					model_ordercenter.query_func = model_ordercenter.orderAllClick;
				},
				
			RepayClick: function(){
				
				switchTab(1);
				$("#allcheck").show();
				$(".ttPay").show();
				model_ordercenter.orderList = [];
				$("#allcheck").attr("checked",false);
				var widget = avalon.vmodels.pp;
				widget.totalItems = 0;
				model_ordercenter.total_orders =  0;
				//_dom.style.borderTop="3px solid #green";
//				/*
				cargo_orderlistRepay( "<%= basePath%>order/search"
					, model_ordercenter.blno
					, model_ordercenter.trucker_phone
					, model_ordercenter.factory_phone
					, model_ordercenter.factory_addr
					, model_ordercenter.starttime
					, model_ordercenter.endtime
					, model_ordercenter.pager.perPages	//	每页显示多少条
					, model_ordercenter.pages		//	显示第几页
				, function(bret,msg, data, total_rows ){
						if( bret )
						{
							if(total_rows == 0){
								$(".nothing_l").show();
							}else{
								$(".nothing_l").hide();
							}
							for( var i = 0; i < data.length; i++ ){
								data[i].statusName = getStatuName(data[i].statu);
								data[i].boxName = getBoxName(data[i].ctype);
								data[i]._createTime = format_unix2str(data[i].createTime);
								data[i]._final_cost = get_property_int("finalCost", data[i]);
								data[i]._suifcaseFee = get_property_int("suifcaseFee",data[i]);
								data[i]._inwardCharge = get_property_int("inwardCharge", data[i]);
								data[i]._truckingAdditionFee = get_property_int("truckingAdditionFee", data[i]);
								data[i]._finalCost = get_property_int("finalCost", data[i]);
								data[i]._totalInsurancePrice = get_property_int("totalInsurancePrice", data[i]);
								
								if ( data[i]._finalCost == 0 ){
									
									data[i]._finalCost=" --.-- ";
								}
								else{
									data[i]._finalCost = data[i]._finalCost.toFixed(2);
								}
								
								var freight = get_property("masterName", data[i]);
								var operator = get_property("masterSlaveName", data[i]);
								if ( operator == "" )
									data[i]._operator = "主账户 " + freight;
								else
									data[i]._operator = "操作员 " + operator;
							}

							model_ordercenter.total_orders =  total_rows;	//	取出总的条数，做分页使用
							model_ordercenter.rePayOrder_count =  total_rows;
							model_ordercenter.orderList = data;	//	根据返回的值绑定订单列表
						}
						else
						{
							alert("订单查询失败:"+ msg );
						}
						
						
					});
					model_ordercenter.tp = 2; 
					//query_func = model_ordercenter.RepayClick;
				},
				
			DoingClick: function(){
				
				switchTab(2);
				$(".ttPay").hide();
				$("#allcheck").hide();
			//	进行中订单查询
				cargo_orderlistDoing( "<%= basePath%>/order/search"
					, ""
					, ""
					, ""
					, ""
					, ""
					, ""
					, model_ordercenter.pager.perPages	//	每页显示多少条
					, model_ordercenter.pages		//	显示第几页
					, function(bret,msg, data, total_rows ){
						if( bret )
						{
							if(total_rows == 0){
								$(".nothing_l").show();
							}else{
								$(".nothing_l").hide();
							}
							for( var i = 0; i < data.length; i++ ){
								data[i].statusName = getStatuName(data[i].statu);
								data[i].carrier = get_property("carrier", data[i]);
								data[i].boxName = getBoxName(data[i].ctype);
								data[i]._createTime = format_unix2str(data[i].createTime);
								data[i]._final_cost = get_property_int("finalCost", data[i]);
								data[i]._suifcaseFee = get_property_int("suifcaseFee",data[i]);
								data[i]._inwardCharge = get_property_int("inwardCharge", data[i]);
								data[i]._truckingAdditionFee = get_property_int("truckingAdditionFee", data[i]);
								data[i]._totalInsurancePrice = get_property_int("totalInsurancePrice", data[i]);
								
								var freight = get_property("masterName", data[i]);
								var operator = get_property("masterSlaveName", data[i]);
								
								if (data[i]._final_cost == 0|| data[i]._final_cost=="undefined"){
									data[i]._final_cost = "--";
								}
								
								if ( operator == "" )
									data[i]._operator = "主账户 " + freight;
								else
									data[i]._operator = "操作员 " + operator;
							}

							model_ordercenter.total_orders =  total_rows;	//	取出总的条数，做分页使用
							model_ordercenter.order_count = total_rows;
							model_ordercenter.orderList = data;	//	根据返回的值绑定订单列表
						}
						else
						{
							alert("订单查询失败:"+ msg );
						}
						
					});
					model_ordercenter.tp = 3; 
					//model_ordercenter.query_func = model_ordercenter.DoingClick;
				},
		
				showTipsClick:function(index){
					model_ordercenter.toolTipsContent = "";
					//	显示附加费明细
					var elm = model_ordercenter.orderList[index];
					var _prefee = (elm.truckingFee*1.2 + elm._totalInsurancePrice);
					
					
					model_ordercenter.toolTipsContent += "预付费:￥"+_prefee.toFixed(2)+"元<br>";
					
					if(typeof(elm.truckingFee) != "undefined"){
						if(elm.truckingFee != "0"){
							model_ordercenter.toolTipsContent += "拖卡费:￥"+(elm.truckingFee - elm._inwardCharge - elm._suifcaseFee)+"元<br>";
						}
					}
					if(typeof(elm._inwardCharge) != "undefined"){
						if(elm._inwardCharge != "0"){
							model_ordercenter.toolTipsContent += "进港费:￥"+elm._inwardCharge+"元<br>";					
						}
					}
					if(typeof(elm._suifcaseFee) != "undefined"){
						if(elm._suifcaseFee != "0"){
							model_ordercenter.toolTipsContent += "提箱费:￥"+elm._suifcaseFee+"元<br>";	
						}
					}
					
					if(typeof(elm._truckingAdditionFee) != "undefined"){
						if(elm._truckingAdditionFee != "0"){
							model_ordercenter.toolTipsContent += "附加费小计:￥"+elm._truckingAdditionFee+"元<br>";	
						}
					}
					
					/*
					if(typeof(elm.additionDetail) != "undefined"){
						if(elm.additionDetail != ""){
							model_ordercenter.toolTipsContent += "附加费详情:<br>"+elm.additionDetail+"<br>";	
						}
					}
					*/
					if(typeof(elm.insurance) != "undefined"){
						if(elm.insurance != ""){
							model_ordercenter.toolTipsContent += "太平洋保费:￥"+elm._totalInsurancePrice+"元<br>";	
						}
					}
// 					if ( elm._final_cost != "0"){
// 						model_ordercenter.toolTipsContent += "应付金额:￥"+elm._final_cost+"元<br>";
// 					}
					
					
//	 				if(typeof(elm.truckingFee) == "undefined"){
//	 					elm.truckingFee = "0";
//	 				}
//	 				if(typeof(elm.inwardCharge) == "undefined"){
//	 					elm.inwardCharge = "0";							
//	 				}
//	 				if(typeof(elm.suifcaseFee) == "undefined"){
//	 					elm.suifcaseFee = "0";
//	 				}
//	 				if(typeof(elm.truckingAdditionFee) == "undefined"){
//	 					elm.truckingAdditionFee = "0";
//	 				}
//	 				if(typeof(elm.additionDetail) == "undefined"){
//	 					elm.additionDetail = "";
//	 				}
//	 				if(typeof(elm.insurance) == "undefined"){
//	 					elm.insurance = "0";
//	 				}
//	 				if(typeof(elm.finalCost) == "undefined"){
//	 					elm.finalCost = "0";
//	 				}
//	 				model_ordercenter.toolTipsContent = "拖卡费:￥"+elm.truckingFee+
//	 						  "元<br>附加费:￥"+elm.truckingAdditionFee+
//	 						  "元<br>附加费详情:"+elm.additionDetail+
//	 						  "<br>太平洋保费:￥"+elm.insurance+
//	 						  "元<br>实付金额:￥"+elm.finalCost
				},
			FinishClick: function(){
				cargo_orderlistFinish( "<%= basePath%>/order/search"
					, ""
					, ""
					, ""
					, ""
					, ""
					, ""
					, model_ordercenter.pager.perPages	//	每页显示多少条
					, model_ordercenter.pages		//	显示第几页
					, function(bret,msg, data, total_rows ){
						if( bret )
						{
							model_ordercenter.total_orders =  total_rows;	//	取出总的条数，做分页使用
							model_ordercenter.orderList = data;	//	根据返回的值绑定订单列表
						}
						else
						{
							alert("订单查询失败:"+ msg );
						}
						
					});
					
					model_ordercenter.query_func = model_ordercenter.FinishClick;
				},
				
				btnClickQuery: function(){
					model_ordercenter.pages = 1;
					var widget = avalon.vmodels.pp;
					widget.currentPage = 1;
					
					if(model_ordercenter.tp == 1){
						model_ordercenter.orderAllClick();
					}else if(model_ordercenter.tp == 2){
						model_ordercenter.RepayClick();
					}else if(model_ordercenter.tp == 3){
						model_ordercenter.DoingClick();
					}else if(model_ordercenter.tp == 4){
						model_ordercenter.FinishClick();
					}
					
//	 				if ( model_ordercenter.query_func != null )
//	 					model_ordercenter.query_func();
				},
			
			//点击取消订单按钮执行该动作
				//点击取消订单按钮执行该动作
				cancelOrderClick: function( dialog, orderindex ){
					//	查询违约金
					model_ordercenter.currentSelect = orderindex;
					var debit = cargo_queryDebit( "<%= basePath%>order/getCancelDedit", model_ordercenter.orderList[model_ordercenter.currentSelect].id );
					if(debit.code == -1 || debit.code == -2 ||debit.code == -3){
						model_ordercenter.currentSelect = -1;
						return;
					}else{
						model_ordercenter.dialogMessage = debit.data;
						if(model_ordercenter.orderList[orderindex].statu == "-1"){
							model_ordercenter.cancelDialogMsg = " 订单一经取消，不可恢复。请确定是否真的要取消订单！";
						}else{
							model_ordercenter.cancelDialogMsg = " 司机已接单，撤销此订单，将会扣除"+model_ordercenter.dialogMessage+"元的运费作为司机的补贴，感谢您的合作！如有其他问题可咨询客服400-166-1697";
						}
						avalon.vmodels[dialog].toggle = true;	//	显示取消订单对话框
					}
					
//	 				if ( debit < 0 ){
//	 					alert("网络出现意外，请重新登录，在结算吧");
//	 					model_ordercenter.currentSelect = -1;
//	 					return;
//	 				}
//	 				else{
						
//	 					model_ordercenter.currentSelect = orderindex;
//	 					model_ordercenter.dialogMessage = debit;
//	 					avalon.vmodels[dialog].toggle = true;	//	显示取消订单对话框
//	 				}
				},
			
			//点击完成订单按钮执行该动作
			finishOrderClick: function( dialog, orderindex ){
				model_ordercenter.currentSelect = orderindex;
				cargo_queryOrderAdditionalFee( "<%= basePath%>order/findOrderAdditionByOrderId", model_ordercenter.orderList[model_ordercenter.currentSelect].id, function( bret,msg, data ){
				model_ordercenter.dialogFeeList = data;
				} );
				
				model_ordercenter.finish_fee = 0;
				model_ordercenter.charge_sheet = [];
				var elm = model_ordercenter.orderList[orderindex];
				if(typeof(elm.truckingFee) != "undefined"){
					if(elm.truckingFee != "0"){						
						var fee={};
//						model_ordercenter.dialogMessage += "拖卡费:￥"+elm.truckingFee+"元";
						
						fee.fee = elm.truckingFee - elm._inwardCharge - elm._suifcaseFee;
						fee.name = "拖卡费";
						model_ordercenter.charge_sheet.push(fee);
						model_ordercenter.finish_fee += fee.fee;
					}
				}
				if(typeof(elm._inwardCharge) != "undefined"){
					if(elm._inwardCharge != "0"){
						var fee={};
						//model_ordercenter.dialogMessage += "进港费:￥"+elm._inwardCharge+"元<br/>";					
						fee.fee = elm._inwardCharge;
						fee.name = "进港费";
						model_ordercenter.charge_sheet.push(fee);
						model_ordercenter.finish_fee += elm._inwardCharge;
					}
				}
				if(typeof(elm._suifcaseFee) != "undefined"){
					if(elm._suifcaseFee != "0"){
						var fee={};
						//model_ordercenter.dialogMessage += "提箱费:￥"+elm._suifcaseFee+"元<br/>";	
						fee.fee = elm._suifcaseFee;
						fee.name = "提箱费";
						model_ordercenter.charge_sheet.push(fee);
						model_ordercenter.finish_fee += elm._suifcaseFee; 
					}
				}
				if(typeof(elm._truckingAdditionFee) != "undefined"){
					if(elm._truckingAdditionFee != "0"){
						var fee={};
						//model_ordercenter.dialogMessage += "附加费总计:￥"+elm._truckingAdditionFee+"元<br/>";	
						fee.fee = elm._truckingAdditionFee;
						fee.name = "附加费小计";
						model_ordercenter.charge_sheet.push(fee);
						model_ordercenter.finish_fee += elm._truckingAdditionFee;  
					}
				}
				
				/*
				if(typeof(elm.additionDetail) != "undefined"){
					if(elm.additionDetail != ""){
						var fee={};
						model_ordercenter.dialogMessage += "附加费详情:<br>"+elm.additionDetail+"<br/>";
						fee.fee = elm.additionDetail;
						fee.name = "附加费详情";
						model_ordercenter.charge_sheet.push(fee);
					}
				}
				*/
				if(typeof(elm.insurance) != "undefined"){
						var fee={};
					if(elm.insurance != ""){
						//model_ordercenter.dialogMessage += "太平洋保费:￥"+elm.insurance+"<br/>";
						fee.fee = elm._totalInsurancePrice;
						fee.name = "太平洋保费";
						model_ordercenter.charge_sheet.push(fee);
						model_ordercenter.finish_fee += elm._totalInsurancePrice;
					}
				}

				//if ( elm._final_cost != "0"){
				//	model_ordercenter.dialogMessage += "应付金额:￥"+elm._final_cost.toFixed(2)+"元<br/>";
				//}					

				//model_ordercenter.dialogMessage += get_property("additionRemark", model_ordercenter.orderList[model_ordercenter.currentSelect]);
				model_ordercenter.currentSelect = orderindex;
				avalon.vmodels[dialog].toggle = true;	//	显示结算订单对话框
			},			//	对话框
			$finishOpt : {
				onConfirm: function(){
				   //	执行订单结算操作
				   cargo_finishOrder("<%= basePath%>order/orderCompleted", model_ordercenter.orderList[model_ordercenter.currentSelect].id ,"",function(_code,msg){
					
					   if(_code==0){
						   alert("结算完成");
						   model_ordercenter.btnClickQuery();
					   }else{
						   alert(msg);
					   }
				   });
			}
			},
			
			//			对话框
			$cancelOpt : {
				onConfirm: function(){
					if( model_ordercenter.currentSelect != -1 ){
						cargo_cancleOrder("<%= basePath%>order/cancel", model_ordercenter.orderList[model_ordercenter.currentSelect].id ,function(_code,msg){
							if(_code==0){
								alert("取消成功");
								model_ordercenter.btnClickQuery();
								
							}else{
								alert(msg);
							}
						}) ;
					}
				}
			},

			$tooltipShow : {
				"contentGetter": function(elem) {
					if(elem && elem.tagName) {
						return model_ordercenter.toolTipsContent;
					}
				},
				delegate: "true",
				positionMy: "right top",
				positionAt: "right bottom+10",
				event: "click",
				width: "150"
	        },
			$skipArray : ["tooltip"],			
		})
		
		
		model_ordercenter.$watch("total_orders", function(v) {
			avalon.log(name);
			var widget = avalon.vmodels.pp ;
			widget.totalItems = v;
                    })
			

		avalon.scan();
// 		model_ordercenter.RepayClick();
 		cargo_rePaycountOrderList("<%= basePath%>order/countOrderList",function(isSuccess,message,data){
			if(isSuccess){
				model_ordercenter.rePayOrder_count = data;
			}else{
				alert("异常");
			}
			
		});
		cargo_DoingcountOrderList("<%= basePath%>order/countOrderList",function(isSuccess,message,data){
			if(isSuccess){
				model_ordercenter.order_count = data;
			}else{
				alert("异常");
			}
			
		});
		
		financeBalanceData(
			"<%= basePath%>finance/getFinance",
								function(charge, availableCharge,frozeCharge) {
									model_ordercenter.charge = charge;
									model_ordercenter.availableCharge = availableCharge;
									model_ordercenter.frozeCharge = frozeCharge;
								});
								
		queryMasterAccountByFreightId("<%= basePath%>master/modH", "<%= masterUserId%>",function(qma,retmsg,data){
				if(qma){
					var enterprise = data.enterprise;
					model_ordercenter.vip=data.vip;
					if ( !model_ordercenter.vip || model_ordercenter.vip == 0 ){
						model_ordercenter.vip = (enterprise.length > 0) ;
					}
				}
			});

		model_ordercenter.DoingClick();
	})
		
		
	</script>
</head>

<body>
	<center>
		<!-- 菜单 -->
		
		<!-- -->
			<div class="main">

				<!-- 左侧菜单 -->
				<div class="nav2" style="width:15%;float:left;"></div>
					<div class="orderInfo_c"  ms-controller="order_region">
							
					<div ms-widget="dialog, cancelOrderDialog, $cancelOpt">
                    取消订单
                    <p style="color:red;" ms-text="cancelDialogMsg"></p>
                </div>
					<div ms-widget="dialog, finishOrderDialog, $finishOpt" >
                    订单费用如下：
					
					<p ms-text="dialogMessage"></p>
						<table class="opr_mag_tab">
							<tr>
								<th class="cth" style="width:17%;">费用名称</th>
								<th class="cth" style="width:17%;">费用</th>
							</tr>
							<tr ms-repeat="charge_sheet" >
								<td ms-text="el.name"></td>
								<td ms-text="el.fee"></td>
							</tr>
						</table>
						<table class="opr_mag_tab">
							<tr>
								<th class="cth" style="width:17%;">应付费</th>
								<th class="cth" style="width:17%;" ms-text="finish_fee"></th>
							</tr>
						</table>
							<!--
						<table class="opr_mag_tab">
							<tr>
								<th class="cth" style="width:10%;">编号</th>
								<th class="cth" style="width:17%;">附加费名称</th>
								<th class="cth" style="width:17%;">费用</th>
								<th class="cth" style="width:22%;">备注</th>
								<th class="cth" style="width:17%;">操作时间</th>
							</tr>
							<tr ms-repeat="dialogFeeList" ms-if-loop="el.carrierAdditionFee > 0">
								<td>{{el.id}}</td>
								<td>{{el.additionName}}</td>
								<td>{{el.carrierAdditionFee}}</td>
								<td>{{el.remark}}</td>
								<td>{{format_unix2str(el.operatTime)}}</td>
							</tr>
						</table>
						-->
                </div>
					
						<div class="userInfo_c">
							<div class="tab_c">
							<shiro:hasAnyRoles name="3,4">
								<table class="userInfoTab_c">
									<tr>
										<td class="infoTd_c"></td>
										<td class="onInsert_c" style="cursor:pointer;" onclick="location.href='<%= basePath%>order/newOrder'">我要下单</td>
									</tr>
									<tr>
										<td class="infoTd_c" ms-text="'账户余额:'+charge+'元'"></td>
										<td class="onCharge_c"  onclick="location.href='<%= basePath%>charge/charge'">充值</td>
									</tr>
								</table>
							</shiro:hasAnyRoles>
							</div>
							<div class="banner" ms-click="RepayClick"  ms-visible="(vip == 1) ||(order_count>0)">
								<div class="pos" ms-text="rePayOrder_count"></div>
							</div>
							<!-- 没升级账户隐藏banner2，#div2 显示banner2_son -->
							<div class="banner2" ms-click="DoingClick" >
								<div class="pos" ms-text="order_count"></div>
							</div>
							<shiro:hasAnyRoles name="3">
								<div class="banner2_son" ms-visible="!(vip | (order_count>0))">
									<div class="son_btn" onclick="location.href='<%= basePath%>freight/module/account/levelAccount.jsp'" style="cursor:pointer;" >升级企业用户</div>
									<div class="son_label">可建立多个子账户</div>
								</div>
							</shiro:hasAnyRoles>
						</div>
						
						<div style="border: 1px solid #ccc;width: 100%;height: auto;margin-top: 30px;float: left;">
							<div class="page" style="float: left;">
								<!-- 没升级的账户隐藏下面这个div -->
								<div ms-visible="(vip == 1) ||(order_count>0)" class="pageDiv" style="cursor:pointer;" ms-click="DoingClick" id="div2">进行中订单</div>
								<div ms-visible="(vip == 1) ||(order_count>0)" class="pageDiv" style="border-top:3px solid #01c6b2;cursor:pointer;" ms-click="RepayClick" id="div1">待付款</div>
								<div class="ttPay" ms-click="toPayOrderList">合并付款</div>
							</div>
					<!-- 	<div class="orderTitle" style="float:left;margin-left:1.5%;">
							<div class="order_til" style="width:30%">线路</div>
							<div class="order_til" style="width:10%">箱型</div>
							<div class="order_til" style="width:13%">线路价格</div>
							<div class="order_til" style="width:10%">司机</div>
							<div class="order_til" style="width:10%">订单状态</div>
							<div class="order_til" style="width:10%">应付资金</div>
							<div class="order_til" style="width:17%">订单操作</div>
						</div> -->
						<%-- <shiro:hasAnyRoles name="3,4">
						<div class="orderMes" ms-repeat="orderList" style="float:left;margin-left:1.5%;">
							<div class="order_t">
								<input type="checkbox" ms-if-loop="el.statu == -1" name="payOrderIds" ms-value="{{el.id}}" style="width: 5%;height: 15px;line-height: 15px;float: left;text-align: left;text-indent: 1.6em;">
								<div class="createDate">{{el._createTime}}  {{el._operator}}</div>
								<div class="orderNum">提单号：{{el.blNo}}</div>
							</div>
							<ul>
								<li class="Place_item">
									<div class="zxPlace">
										<div class="zxplace_tr">装箱地点：</div>
										<div class="zxplace_td">{{el.orignPlace}}</div>
									</div>
									<div class="portWharf">
										<div class="portWharf_tr">进港码头：</div>
										<div class="portWharf_td">{{el.destPlace}}</div>
									</div>
								</li>
								<li class="boxType_item">
									<div class="boxType">{{el.boxName}}</div>
								</li>
								<li class="price_item">
									<div class="price">¥{{el.truckingFee}}元</div>
									<div class="cant">冻结资金</div>
									<div class="cant_price">¥{{((el.truckingFee)*1.2 +　el._totalInsurancePrice).toFixed(2)}}元</div>
								</li>
								<li class="driver_item">
									<div class="driver_name">{{el.carrier}}</div>
									<div class="driver_tel">{{el.carrierPhone}}</div>
								</li>
								<li class="orderStatus">
									<div class="status">状态：{{el.statusName}}</div>
								</li>
								<li class="costs_item">
									<div class="costs">¥{{el._final_cost}}元</div>
									<div class="selectDetailed" 
										ms-widget="tooltip,ppoo,$tooltipShow"
										ms-click="showTipsClick($index)">查看明细</div>
								</li>
								<li class="operation">
								<div class="payBtn" ms-if-loop="el.statu == -1" ms-click="orderPayment(el.id)" >付款</div>
								<div class="orderDetailed"><a ms-attr-href="<%=basePath %>order/orderDetails?orderNo={{el.id}}">订单详情</a></div>
								<div class="orderDetailed" ms-if-loop="(el.statu < 4) || (el.statu == 10) || (el.statu == 11) || (el.statu == 9)"><div ms-click="cancelOrderClick( 'cancelOrderDialog', $index)">取消订单</div></div>
								
								<div class="orderDetailed"  ms-if-loop="el.statu == 8"><div ms-click="finishOrderClick( 'finishOrderDialog', $index)">订单结算</div></div>
							</li>
							</ul>
						</div>
						</shiro:hasAnyRoles> --%>
						<div ms-widget="dialog, pDialog,$payDialog" >
				        	<table>
					           	<tr>
					           		<td ms-text="'可用余额：'+availableCharge+'元'"></td>
									<td ms-text="'支付金额：'+finalPayMoney+'元'"></td>
					           	</tr>
					           </table>
				        </div>
				        <div ms-widget="dialog, cDialog,$chargeDialog" >
				        	<table>
					           	<tr>
					           		<td ms-text="'可用余额：'+availableCharge+'元'"></td>
									<td ms-text="'支付金额：'+finalPayMoney+'元'"></td>
					           	</tr>
					           </table>
					           <p style="color:red;">您的余额不足，请充值后再付款~</p>
				        </div>
						
						 <div class="content_type">
                           
                                 
                                    <ul class="tab">
	                                   <li  style="width: 8%;text-align: center;"><input id="allcheck" type="checkbox" onclick="sel(this)" style="width:100%;height:15px;"/></li>
	                                   <li class="li_1" style="width:22%;">线路</li>
	                                   <li class="li_2">箱型</li>
	                                   <li class="li_3">线路价格</li>
	                                   <li class="li_4">司机</li>
	                                   <li class="li_5">订单状态</li>
	                                   <li class="li_6">实付资金</li>
	                                   <li class="li_7">操作订单</li>
                                   </ul>
                                   
                <shiro:hasAnyRoles name="3,4">
                    <div class="tab_div" ms-repeat="orderList">
                                    <ul class="tab_2_head">
                                        <li>
                                        <input type="checkbox" ms-if-loop="el.statu == -1" name="payOrderIds" ms-value="{{el.id}}_{{((el.truckingFee)*1.2 + el._totalInsurancePrice).toFixed(2)}}" style="width: 5%;height: 15px;line-height: 15px;float: left;text-align: left;text-indent: 1.6em;" ms-text="moment(el._createTime).format("YYYY-MM-DD")">
                                          <label ms-text="el._operator"></label>  &nbsp&nbsp&nbsp<label ms-text="'提单号：'+el.blNo"></label>
                                        </li>
                                     
	                                </ul>
                                     <ul class="tab_2" id="content">
	                                     <li class="li_1" style="text-align:left;padding:10px 0px 0px 10px;">
                                             <p>装箱地点：<label ms-text="el.orignPlace"></label></p> 
                                                <br>
                                              <p>进港码头：<label ms-text="el.destPlace"></label></p>
	                                     </li>
	                                     <li class="li_2"> 
		                                                <label ms-text="el.boxName"></label>		                                   
	                                     </li>
	                                     <li class="li_3">
		                                         <label ms-text="'¥'+el.truckingFee.toFixed(2)+'元'"></label>
                                                  <p class="fade_word">冻结资金</p>
                                                  <p class="fade_word" ms-text="'￥'+((el.truckingFee)*1.2 + el._totalInsurancePrice).toFixed(2)+'元'"></p>
	                                     </li>
	                                     <li class="li_4">
	                                     
		                                          <label class="driver_name"><span class="driver_img" ms-visible="el.carrier"><img src="<%= basePath%>freight/img/no_message.png"></span><span ms-text="el.carrier"></span></label>
                                                  <p class="driver_tel" ms-text="el.carrierPhone"></p>
	                                     </li>
	                                     <li class="li_5">
		                                           <label ms-if-loop="el.statu == 11" style="color:#ccc;" ms-text="el.statusName"></label>
		                                           <label ms-if-loop="el.statu == -1" style="color:red;" ms-text="el.statusName"></label>
		                                           <label ms-if-loop="el.statu != -1 && el.statu != 11" ms-text="el.statusName"></label>
	                                     </li>
	                                     <li class="li_6">
                                                   <label ms-text="'￥'+((el._finalCost=='undefined'||el._finalCost==0||el._finalCost==null)?'--.--':el._finalCost)+'元'"></label>
                                                   <p><a class="selectDetailed" 
										ms-widget="tooltip,ppoo,$tooltipShow"
										ms-click="showTipsClick($index)">查看明细</a></p>
	                                    </li>
	                                    <li class="li_7">
                                <div class="payBtn" ms-if-loop="el.statu == -1" ms-click="orderPayment(el.id,(((el.truckingFee)*1.2 + el._totalInsurancePrice).toFixed(2)))" >付款</div>
								<div class="orderDetailed"><a ms-attr-href="<%=basePath %>order/orderDetails?orderNo={{el.id}}">订单详情</a></div>
								<div class="orderDetailed" ms-if-loop="(el.statu < 4) || (el.statu == 10) || (el.statu == 11) || (el.statu == 9)"><div ms-click="cancelOrderClick( 'cancelOrderDialog', $index)">取消订单</div></div>
								
								<div class="orderDetailed"  ms-if-loop="el.statu == 8"><div ms-click="finishOrderClick( 'finishOrderDialog', $index)">订单结算</div></div>
	                                    </li>
                                      </ul>
                                </div>
              </shiro:hasAnyRoles>
             </div> 

						<div ms-widget="pager, pp"></div>
						</div>
						<!-- 加载无数据时请控制显示此div -->
					<div class="nothing_l" style="width:85%;display:none;float:left;"><div style="width:100%;height:100px;line-height:100px;">您还没有下过订单，暂时没有订单查看噢。</div><a href="<%= basePath%>order/newOrder" style="  width: 20%;height: 50px;line-height: 50px;border: 2px solid #01c6b2;color: #01c6b2;font-weight: bold;margin: 0 auto;">我要下单</a>
					</div>
					</div>
				</div>
			</div>
			<div style="width:100%;height:70px;float:left;"></div>
			<div style="clear:both;"></div>
			<div class="nav3"></div>
				

	</center>
	<script type="text/javascript">
	function getInfo(){ 
	
		if(window.screen.width>1024){
		
			$(".main").width(1200);
		}else if(window.screen.width == 1024){
			$(".main").width(1024);
		}
    }
    getInfo();
	</script>
</body>
