<%@ page language="java"
	import="java.util.*,com.icargo.entiy.UserSession" pageEncoding="utf-8"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme() + "://"
			+ request.getServerName() + ":" + request.getServerPort()
			+ path + "/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<base href="<%=basePath%>">
<jsp:include page="/newpages/common/head_common1.jsp"></jsp:include>
<script type="text/javascript">
$(function(){
	$.ajax({
		url : _basePath+"finance/getFinance",
		async : true,
		type : 'post',
		data : {},
		cache : false,
		success : function(_data) {
			if(_data!=null &&_data.charge!=null && _data.availableCharge!=null){
				
				$("#left_money").html("<label style='color: #6FC2EE;font-size: 17px'>"+_data.availableCharge+"</label>&nbsp;元 ");
			}
			else
				{
				$("#left_money").html("<label style='color: #6FC2EE;font-size: 17px'>0</label>&nbsp;元 ");
				}
		}
	});
	
	$.ajax({
		url : _basePath+"order/findVehicleAgencyFund?filterStatuStr=1,2,3,4,8&vehicleGroupUserId=",
		async : true,
		type : 'post', 
		data : {}, 
		cache : false,
		success : function(_data) {
			if(_data.code == 0){
				$("#earge_money").html("<label style='color: #6FC2EE;font-size: 17px'>"+_data.data+"</label>&nbsp;元 ");
			} else{
				$("#earge_money").html("<label style='color: #6FC2EE;font-size: 17px'>0</label>&nbsp;元 ");
			}
		}
	});
	$('#mainTable').datagrid({
		/* title:"订单列表",  *///标题
		method:'post',
		iconCls:'icon-edit', //图标
		singleSelect:true, //多选
		height:400, //高度
		fitColumns: true, //自动调整各列，用了这个属性，下面各列的宽度值就只是一个比例。
		striped: true, //奇偶行颜色不同
		collapsible:true,//可折叠
		url:"order/search?filterStatuStr=1,2,3,4,5,7,8", //数据来源
		queryParams:{}, //查询条件
		pageSize:10,
		pageList:[10,20,25,30,35,40,45,50],
		pagination:true, //显示分页
		rownumbers:false, //显示行号
		checkbox: true,
		border:false,
		columns:[[
                        {field:'createTime',title:'订单创建时间',width:25,
	                       formatter:function(value,data,index){
		                 return mygetDate(data.createTime);
	                      }
                          },
                        {field:'handlingTime',title:'装卸时间',width:25,
	                     formatter:function(value,data,index){
		                    return mygetDate(data.handlingTime);
	                       }
                           },
						{field:'blNo',title:'提单号',width:10,
						formatter:function(value,data,index){
							return data.blNo;
						}
						},
						{field:'price',title:'价格',width:10,
							formatter:function(value,data,index){
								var orderid=data.id;
							var s=getOrderPrice(orderid);
							return s;
								
							}
						},
						  {field:'ctype',title:'箱型',width:7,
							formatter:function(value,data,index){
								return _findByCateAndValue(1,data.ctype);
							}
						},
					 	{field:'carrier',title:'做单司机',width:12,
							formatter:function(value,data,index){
								return data.carrier;
							}
						},
                      
						{field:'carrierPhone',title:'司机电话',width:5,
							formatter:function(value,data,index){
								return data.carrierPhone;
							}
						},
						{field:'yard',title:'提箱堆场',width:17,
							formatter:function(value,data,index){
								return data.yard;
							}
						},{field:'destPlace',title:'进港码头',width:22,
							formatter:function(value,data,index){
								return data.destPlace;
							}
						},{field:'statu',title:'订单状态',width:10,
						formatter:function(value,data,index){
								 /* m= _findByCateAndValue(2,data.statu); */ 
								 var m;
								if(data.statu=='5'||data.statu=='7')
									{m= "已结算"}
								else 
									{
									m="待结算";
									}
								return m; 
							}
						},					
						{field:'remark',title:'备注',width:20,
							formatter:function(value,data,index){
								return data.remark;
							}
						},

						
		]],
		onLoadSuccess:function(){
			$('#mainTable').datagrid('clearSelections'); 
		},
		onDblClickRow :function(rowIndex,rowData){
			var row = $('#mainTable').datagrid('getSelected').id;
			var param="id="+row;
			//隐藏确认完成订单
			$("#confirm").attr("style","display: none;");
			getOrderDetailAndActionShowTable(row);
	    }	    
	})
    });
    
    function getOrderPrice(order)
    {
    	var param='order='+order;
    	var t;
    var price=	$.ajax({
    	url:_basePath+'order/findOrderVehicleFee',
		type:'post',
		async:false,
		dateType:"json",
		data:param,
		success:function(da){
			 var enterp=da.data;
			 t=enterp;
		}
    		
    	});
    return t;
    }
    
    
</script>
<style type="text/css">
.show_data
{
padding:20px;
}
.show_data td
{
padding:10px
}
</style>
</head>
<body >
<table class="show_data">
<tr>
<td>
账户余额：
</td>
<td id="left_money" >
</td>
</tr>
<tr>
<td>
待收款金额：
</td>
<td id="earge_money">
</td>
</tr>
</table>
<form  id="queryForm_1" name="queryForm_1">
<table>
<tr>
<td>
查询时间范围:  
</td>
<td>
<!-- <input type="date" name="startTime" id="startTime"> -->
<input class="boot" onfocus="WdatePicker({skin:'twoer',dateFmt:'yyyy-MM-dd HH:mm:ss',maxDate:'#F{$dp.$D(\'endTime\')}'})"  name="startTime" id="startTime" style="color:#aaa" />
</td>
<td>
—
</td>
<td>
<!-- <input type="date" name="endTime" id="endTime"> -->
<input class="boot" onfocus="WdatePicker({skin:'twoer',dateFmt:'yyyy-MM-dd HH:mm:ss',minDate:'#F{$dp.$D(\'startTime\')}'})" name="endTime" id="endTime" style="color:#aaa" />
</td>
<td>
司机电话：
</td>
<td>
<input type="text" name="carrierPhone" id="carrierPhone">
</td>
<td>
<a href="javascript:void(0)" id="query_1" onclick="_search('mainTable','queryForm_1')" class="boot" style="background-color: #8cc952;width:70px;display: block;text-decoration: none;height: 20px;" >查询</a>
</td>
</tr>
</table>
</form>
		<table id="mainTable"></table>
</body>
</html>
