<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page contentType="text/html;charset=windows-1252"%>
<%@ page import="java.util.Vector"%>
<%@ page import="org.LexGrid.concepts.Entity" %>
<%@ page import="gov.nih.nci.evs.browser.common.Constants" %>
<%@ page import="gov.nih.nci.evs.browser.utils.*" %>
<%@ page import="gov.nih.nci.evs.browser.bean.IteratorBean" %>
<%@ page import="org.LexGrid.LexBIG.DataModel.Core.ResolvedConceptReference" %>
<%@ page import="javax.faces.context.FacesContext" %>
<%@ page import="org.apache.log4j.*" %>
<%@ page import="gov.nih.nci.evs.browser.utils.*" %>
<%@ page import="org.lexgrid.valuesets.LexEVSValueSetDefinitionServices" %>

<script type="text/javascript" src="<%= request.getContextPath() %>/js/yui/yahoo-min.js" ></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/yui/event-min.js" ></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/yui/dom-min.js" ></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/yui/animation-min.js" ></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/yui/container-min.js" ></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/yui/connection-min.js" ></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/yui/autocomplete-min.js" ></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/yui/treeview-min.js" ></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/dropdown.js"></script>

<% String vsBasePath = request.getContextPath(); %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns:c="http://java.sun.com/jsp/jstl/core">
<head>
  <title>NCI Thesaurus</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" type="text/css" href="<%= request.getContextPath() %>/css/styleSheet.css" />
  <link rel="shortcut icon" href="<%= request.getContextPath() %>/favicon.ico" type="image/x-icon" />
  <link rel="stylesheet" type="text/css" href="<%= request.getContextPath() %>/css/yui/fonts.css" />
  <link rel="stylesheet" type="text/css" href="<%= request.getContextPath() %>/css/yui/grids.css" />
  <link rel="stylesheet" type="text/css" href="<%= request.getContextPath() %>/css/yui/code.css" />
  <link rel="stylesheet" type="text/css" href="<%= request.getContextPath() %>/css/yui/tree.css" />
  <script type="text/javascript" src="<%= request.getContextPath() %>/js/script.js"></script>

  <script type="text/javascript">
  
    function refresh() {
      
      var selectValueSetSearchOptionObj = document.forms["valueSetSearchForm"].selectValueSetSearchOption;
      
      for (var i=0; i<selectValueSetSearchOptionObj.length; i++) {
        if (selectValueSetSearchOptionObj[i].checked) {
            selectValueSetSearchOption = selectValueSetSearchOptionObj[i].value;
        }
      }
      
      window.location.href="/ncitbrowser/pages/value_set_terminology_view.jsf?refresh=1"
          + "&nav_type=valuesets" + "&opt="+ selectValueSetSearchOption;


    }
  </script>
  
</head>

<body onLoad="document.forms.valueSetSearchForm.matchText.focus();">
  <script type="text/javascript" src="<%= request.getContextPath() %>/js/wz_tooltip.js"></script>
  <script type="text/javascript" src="<%= request.getContextPath() %>/js/tip_centerwindow.js"></script>
  <script type="text/javascript" src="<%= request.getContextPath() %>/js/tip_followscroll.js"></script>
<%!
  private static Logger _logger = Utils.getJspLogger("value_set_search_results.jsp");
%>

<%
    String searchform_requestContextPath = request.getContextPath();
    searchform_requestContextPath = searchform_requestContextPath.replace("//ncitbrowser//ncitbrowser", "//ncitbrowser");

    String message = (String) request.getSession().getAttribute("message");
    request.getSession().removeAttribute("message");
    String t = null;
    
    String selected_cs = "";
    String selected_cd = null;

    String check_cs = "";
    String check_cd = "";
    String check_code = "";
    String check_name = "";
    String check_src = "";
    
    // to be modified
    String valueset_search_algorithm = null;

    String check__e = "", check__b = "", check__s = "" , check__c ="";
    if (valueset_search_algorithm == null || valueset_search_algorithm.compareTo("exactMatch") == 0)
        check__e = "checked";
    else if (valueset_search_algorithm.compareTo("startsWith") == 0)
        check__s= "checked";
    else if (valueset_search_algorithm.compareTo("DoubleMetaphoneLuceneQuery") == 0)
        check__b= "checked";
    else
        check__c = "checked";
        
    String selectValueSetSearchOption = null;
    selectValueSetSearchOption = (String) request.getParameter("opt");
    
    if (selectValueSetSearchOption == null) {
        selectValueSetSearchOption = (String) request.getSession().getAttribute("selectValueSetSearchOption");
    }
               
    if (selectValueSetSearchOption == null || selectValueSetSearchOption.compareTo("null") == 0) {
        selectValueSetSearchOption = "Code";
    }

    if (selectValueSetSearchOption.compareTo("CodingScheme") == 0)
        check_cs = "checked";
    else if (selectValueSetSearchOption.compareTo("Code") == 0)
        check_code = "checked";
    else if (selectValueSetSearchOption.compareTo("Name") == 0)
        check_name = "checked";        
    else if (selectValueSetSearchOption.compareTo("Source") == 0)
        check_src = "checked";
    String valueset_match_text = "";
%>

<f:view>
  <!-- Begin Skip Top Navigation -->
    <a href="#evs-content" class="hideLink" accesskey="1" title="Skip repetitive navigation links">skip navigation links</A>
  <!-- End Skip Top Navigation --> 
  <%@ include file="/pages/templates/header.jsp" %>
  <div class="center-page">
    <%@ include file="/pages/templates/sub-header.jsp" %>
    <!-- Main box -->
    <div id="main-area">
   
   
<%

String valueSetSearch_requestContextPath = request.getContextPath();

String selected_ValueSetSearchOption = (String) request.getSession().getAttribute("selectValueSetSearchOption"); 


Vector vsd_vec = null;

String vsd_uri = (String) request.getParameter("vsd_uri"); 
System.out.println("value_set_search_results.jsp vsd_uri: " + vsd_uri);

String selectedvalueset = null;
if (vsd_uri != null && vsd_uri.compareTo("null") != 0) { 
    String vsd_metadata = DataUtils.getValueSetDefinitionMetadata(DataUtils.findValueSetDefinitionByURI(vsd_uri));
    vsd_vec = new Vector();
    vsd_vec.add(vsd_metadata);
    
} else {
    vsd_vec = (Vector) request.getSession().getAttribute("matched_vsds");
    if (vsd_vec != null && vsd_vec.size() == 1) {
	vsd_uri = (String) vsd_vec.elementAt(0);
	
	Vector temp_vec = DataUtils.parseData(vsd_uri);
	selectedvalueset = (String) temp_vec.elementAt(1);
    }
}   

System.out.println("(*) value_set_search_results.jsp vsd_uri: " + vsd_uri);
%>
   
   
      <!-- Thesaurus, banner search area -->
      <div class="bannerarea">
      
<%
if (vsd_vec != null && vsd_vec.size() > 1) {
%>

      
        <div class="banner">
            <a href="<%=basePath%>/start.jsf"><img src="<%=basePath%>/images/evs_termsbrowser_logo.gif" width="383" height="117" alt="Thesaurus Browser Logo" border="0"/></a>
        </div>


<%
} else {

   vsd_uri = (String) vsd_vec.elementAt(0);
   Vector temp_vec = DataUtils.parseData(vsd_uri);
   String vsd_name = (String) temp_vec.elementAt(0);



%>

    <div class="banner">
	    <a class="vocabularynamebanner" href="<%=request.getContextPath()%>/pages/value_set_search_results.jsf?uri=<%=HTTPUtils.cleanXSS(vsd_uri)%>">
      
	<div class="vocabularynamebanner">
	
<%
if (vsd_name.length() < HTTPUtils.ABS_MAX_STR_LEN) {
%>
	
		  <div class="vocabularynameshort" STYLE="font-size: <%=HTTPUtils.maxFontSize(vsd_name)%>px; font-family : Arial">
		    <%=HTTPUtils.cleanXSS(vsd_name)%>
		  </div>
<%		  
} else {

System.out.println("Using small font.");
%>


		  <div class="vocabularynameshort" STYLE="font-size:x-small; ">
		    <%=HTTPUtils.cleanXSS(vsd_name)%>
		  </div>

<%
}
%>
		  
		  
		  
	</div>
  
	    </a>
    

    </div>


<%
} 
%>


        <div class="search-globalnav">
          <!-- Search box -->
          <div class="searchbox-top"><img src="<%=basePath%>/images/searchbox-top.gif" width="352" height="2" alt="SearchBox Top" /></div>
          <div class="searchbox">
          
            <h:form id="valueSetSearchForm" styleClass="search-form"> 
              <div class="textbody">          
                <% if (selectValueSetSearchOption.compareTo("CodingScheme") == 0) { %>
                  <input CLASS="searchbox-input-2"
                    name="matchText"
                    value=""
                    onkeypress="return submitEnter('valueSetSearchForm:valueset_search',event)"
                    tabindex="1"/>
                <% } else { %>
                  <input CLASS="searchbox-input-2"
                    name="matchText"
                    value="<%=valueset_match_text%>"
                    onFocus="active = true"
                    onBlur="active = false"
                    onkeypress="return submitEnter('valueSetSearchForm:valueset_search',event)"
                    tabindex="1"/>
                <% } %>  
                	    
                <h:commandButton id="valueset_search" value="Search" action="#{valueSetBean.valueSetSearchAction}"
                  onclick="javascript:cursor_wait();"
                  image="#{valueSetSearch_requestContextPath}/images/search.gif"
                  styleClass="searchbox-btn"
                  alt="Search"
                  tabindex="2">
                </h:commandButton>
                
                <h:outputLink
                  value="#{facesContext.externalContext.requestContextPath}/pages/help.jsf#searchhelp"
                  tabindex="3">
                  <h:graphicImage value="/images/search-help.gif" styleClass="searchbox-btn"
                  style="border-width:0;"/>
                </h:outputLink> 
            
                <input type="radio" id="selectValueSetSearchOption" name="selectValueSetSearchOption" value="Code" <%=check_code%> 
                  alt="Code" tabindex="1" onclick="javascript:refresh()" >Code&nbsp;
                <input type="radio" id="selectValueSetSearchOption" name="selectValueSetSearchOption" value="Name" <%=check_name%> 
                  alt="Name" tabindex="1" onclick="javascript:refresh()" >Name&nbsp;
                <input type="radio" id="selectValueSetSearchOption" name="selectValueSetSearchOption" value="Source" <%=check_src%> 
                  alt="Source" tabindex="1" onclick="javascript:refresh()" >Source&nbsp;
                <input type="radio" id="selectValueSetSearchOption" name="selectValueSetSearchOption" value="CodingScheme" <%=check_cs%> 
                  alt="Coding Scheme" tabindex="1" onclick="javascript:refresh()" >Terminology
                <br/>
              
                <% if (selectValueSetSearchOption.compareToIgnoreCase("Code") == 0 || 
                       selectValueSetSearchOption.compareToIgnoreCase("Name") == 0) { %>    
                    <input type="radio" name="valueset_search_algorithm" value="exactMatch" alt="Exact Match" <%=check__e%> tabindex="3">Exact Match&nbsp;
                    <input type="radio" name="valueset_search_algorithm" value="startsWith" alt="Begins With" <%=check__s%> tabindex="3">Begins With&nbsp;
                    <input type="radio" name="valueset_search_algorithm" value="contains" alt="Contains" <%=check__c%> tabindex="3">Contains
                <% } else if (selectValueSetSearchOption.compareToIgnoreCase("Source") == 0) {
                    request.setAttribute("globalNavHeight", "54"); 
                   } else if (selectValueSetSearchOption.compareToIgnoreCase("CodingScheme") == 0) { %>
                    &nbsp;&nbsp;
                    <h:outputLabel id="codingschemelabel" value="Terminology: " styleClass="textbody">
                      <h:selectOneMenu id="selectedOntology" value="#{valueSetBean.selectedOntology}"
                          immediate = "true"
                          valueChangeListener="#{valueSetBean.ontologyChangedEvent}">
                        <f:selectItems value="#{valueSetBean.ontologyList}"/>
                      </h:selectOneMenu>
                    </h:outputLabel>
                <% } %>
              
                <input type="hidden" name="referer" id="referer" value="<%=HTTPUtils.getRefererParmEncode(request)%>">
                <input type="hidden" id="nav_type" name="nav_type" value="valuesets" />
              </div> <!-- textbody -->      
            </h:form>
          </div> <!-- searchbox -->
          
          <div class="searchbox-bottom"><img src="<%=basePath%>/images/searchbox-bottom.gif" width="352" height="2" alt="SearchBox Bottom" /></div>
          <!-- end Search box -->
          <!-- Global Navigation -->
          <%@ include file="/pages/templates/menuBar-termbrowser.jsp" %>
          <!-- end Global Navigation -->
        </div> <!-- search-globalnav -->
      </div> <!-- bannerarea -->
      
      <!-- end Thesaurus, banner search area -->
      <!-- Quick links bar -->
      <%@ include file="/pages/templates/quickLink.jsp" %>
      <!-- end Quick links bar -->

      <!-- Page content -->
      <div class="pagecontent">
        <div id="popupContentArea">
          <a name="evs-content" id="evs-content"></a>


          <%-- 0 <%@ include file="/pages/templates/navigationTabs.jsp"%> --%>
          <div class="tabTableContentContainer">
          
          <table>
            <tr>

<%

if (vsd_vec != null && vsd_vec.size() > 1) {
%>     
    <td class="texttitle-blue">Matched Value Sets:</td>
<%
}
%>
            </tr>

            <% if (message != null) { %>
        <tr class="textbodyred"><td>
      <p class="textbodyred">&nbsp;<%=message%></p>
        </td></tr>
            <% } else { %>


 <h:form id="valueSetSearchResultsForm" styleClass="search-form">            

            <tr class="textbody"><td>
 
 
 <%
 if (vsd_vec != null && vsd_vec.size() == 1) {
 %>
 <div id="message" class="textbody">
    <table border="0" width="700px">
     <tr>
       <td>
          <div class="texttitle-blue">Welcome</div>
       </td>
       
       <td class="dataCellText" align="right">
                      <h:commandButton id="Values" value="Values" action="#{valueSetBean.resolveValueSetAction}"
                        onclick="javascript:cursor_wait();"
                        image="#{valueSetSearch_requestContextPath}/images/values.gif"
                        alt="Values"
                        tabindex="3">
                      </h:commandButton>                  
                    &nbsp;
                      <h:commandButton id="versions" value="versions" action="#{valueSetBean.selectCSVersionAction}"
                        onclick="javascript:cursor_wait();"
                        image="#{valueSetSearch_requestContextPath}/images/versions.gif"
                        alt="Versions"
                        tabindex="2">
                      </h:commandButton>
                    &nbsp;
                      <h:commandButton id="xmldefinition" value="xmldefinition" action="#{valueSetBean.exportVSDToXMLAction}"
                        onclick="javascript:cursor_wait();"
                        image="#{valueSetSearch_requestContextPath}/images/xmldefinitions.gif"
                        alt="XML Definition"
                        tabindex="2">
                      </h:commandButton>
       
       </td>
     </tr>
   </table>  
   <hr/>
 </div>
 
 <%
 }
 %> 
  
 
 <%
 if (vsd_uri != null) {
  
 %>
 
    <input type="hidden" name="valueset" value="<%=vsd_uri%>">&nbsp;</input>
    
<%
 }
 %>

 
              <table class="dataTable" summary="" cellpadding="3" cellspacing="0" border="0" width="100%">

<%
if (vsd_vec != null && vsd_vec.size() > 1) {
%> 
		<th class="dataTableHeader" scope="col" align="left">&nbsp;</th>
		
		
                <th class="dataTableHeader" scope="col" align="left">Name</th>
                <!--
                <th class="dataTableHeader" scope="col" align="left">URI</th>
                <th class="dataTableHeader" scope="col" align="left">Description</th>
                -->
                <th class="dataTableHeader" scope="col" align="left">Concept Domain</th>
                <th class="dataTableHeader" scope="col" align="left">Sources</th>
		
		
<%
}
%>		
		


<%
if (vsd_vec != null) {
            for (int i=0; i<vsd_vec.size(); i++) {
            
		    String vsd_str = (String) vsd_vec.elementAt(i);
	    
		    Vector u = DataUtils.parseData(vsd_str);
		    
		    String name = (String) u.elementAt(0);
		    String uri = (String) u.elementAt(1);
		    String label = (String) u.elementAt(2);
		    String cd = (String) u.elementAt(3);
		    String sources = (String) u.elementAt(4);


if (vsd_vec.size() > 1)
{
		    if (i % 2 == 0) {
		    %>
		      <tr class="dataRowDark">
		    <%
			} else {
		    %>
		      <tr class="dataRowLight">
		    <%
			}
		    %>  
		    
<%		    
} else {
%>
    <tr>
<%
}
%>
		
<%		
if (vsd_vec != null && vsd_vec.size() > 1) {
%>		

                <td>
                <%
                if (i == 0) {
                %>
                <input type=radio name="valueset" value="<%=uri%>" checked >&nbsp;</input>
                <%
                } else {
                %>
                
		<input type=radio name="valueset" value="<%=uri%>">&nbsp;</input>
		
		<%
		}
		%>
		
		</td>
<%		
}
%>

<%
if (vsd_vec != null && vsd_vec.size() == 1) {
    //if (sources == null || sources.compareTo("") == 0) sources = "not available";
    
    String vsd_description = ValueSetHierarchy.getValueSetDecription(vsd_uri);
    if (vsd_description == null) {
        vsd_description = "DESCRIPTION NOT AVAILABLE";
    }
    
%>
		      <td class="dataCellText">
		      <p>
			 <b><%=name%></b>
		      </p>
		      
		      <p class="dataCellText">
		      
		      <%=vsd_description%>

		      
		      </p>
		      
		      </td>
		      

		      
		      
<%		
} else {
%>		      
		      
		      <td class="dataCellText">
                         <a href="<%=request.getContextPath() %>/pages/value_set_search_results.jsf?vsd_uri=<%=uri%>"><%=name%></a>
		      </td>
		      

		      <td class="dataCellText">
			 <%=cd%>
		      </td>
		      <td class="dataCellText">
			 <%=sources%>
		      </td>  

<%		
} 
%>

		      </tr>
              
              
             <%
                }
             }
             %>                 
              </table>
 
 
 
 
 <%
 if (vsd_vec != null && vsd_vec.size() > 1) {
%>
 
                   <tr><td class="dataCellText">
                     <h:commandButton id="Values" value="Values" action="#{valueSetBean.resolveValueSetAction}"
                       onclick="javascript:cursor_wait();"
                       image="#{valueSetSearch_requestContextPath}/images/values.gif"
                       alt="Values"
                       tabindex="3">
                     </h:commandButton>                  
                   &nbsp;
                     <h:commandButton id="versions" value="versions" action="#{valueSetBean.selectCSVersionAction}"
                       onclick="javascript:cursor_wait();"
                       image="#{valueSetSearch_requestContextPath}/images/versions.gif"
                       alt="Versions"
                       tabindex="2">
                     </h:commandButton>
                   &nbsp;
                     <h:commandButton id="xmldefinition" value="xmldefinition" action="#{valueSetBean.exportVSDToXMLAction}"
                       onclick="javascript:cursor_wait();"
                       image="#{valueSetSearch_requestContextPath}/images/xmldefinitions.gif"
                       alt="XML Definition"
                       tabindex="2">
                     </h:commandButton>
                  </td></tr>


<%
}
%>


<%		
if (vsd_vec != null && vsd_vec.size() == 1) {
%>		
    <input type="hidden" name="vsd_uri" id="vsd_uri" value="<%=vsd_uri%>">	
<%
}
%>

          
              <input type="hidden" name="referer" id="referer" value="<%=HTTPUtils.getRefererParmEncode(request)%>">
</h:form>
            
          </td></tr>
          
          
 <% } %>
          
          
        </table>
        </div> <!-- end tabTableContentContainer -->
         
          
        </div> <!--  popupContentArea -->
        
        <div class="popupContentAreaWithoutBorder">        
          <%@ include file="/pages/templates/nciFooter.jsp" %>
        </div>
      </div> <!-- pagecontent -->
    </div> <!-- main-area -->
    <!-- end Main box -->
  </div> <!-- center-page -->
  <div class="mainbox-bottom"><img src="<%=basePath%>/images/mainbox-bottom.gif" width="745" height="5" alt="Mainbox Bottom" /></div>
</f:view>
</body>
</html>


