<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page contentType="text/html;charset=windows-1252"%>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*"%>
<%@ page import="org.LexGrid.concepts.Entity" %>
<%@ page import="gov.nih.nci.evs.browser.bean.*" %>
<%@ page import="gov.nih.nci.evs.browser.utils.*" %>
<%@ page import="gov.nih.nci.evs.browser.properties.*" %>
<%@ page import="gov.nih.nci.evs.browser.utils.*" %>
<%@ page import="javax.faces.context.FacesContext" %>
<%@ page import="org.LexGrid.LexBIG.DataModel.Core.ResolvedConceptReference" %>
<%@ page import="org.apache.log4j.*" %>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns:c="http://java.sun.com/jsp/jstl/core">
<head>
  <title>NCI Thesaurus</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" type="text/css" href="<%= request.getContextPath() %>/css/styleSheet.css" />
  <link rel="shortcut icon" href="<%= request.getContextPath() %>/favicon.ico" type="image/x-icon" />
  <script type="text/javascript" src="<%= request.getContextPath() %>/js/script.js"></script>
  <script type="text/javascript" src="<%= request.getContextPath() %>/js/search.js"></script>
  <script type="text/javascript" src="<%= request.getContextPath() %>/js/dropdown.js"></script>
</head>
<body>
  <script type="text/javascript"
    src="<%=request.getContextPath()%>/js/wz_tooltip.js"></script>
  <script type="text/javascript"
    src="<%=request.getContextPath()%>/js/tip_centerwindow.js"></script>
  <script type="text/javascript"
    src="<%=request.getContextPath()%>/js/tip_followscroll.js"></script>


  <%!
    private static Logger _logger = Utils.getJspLogger("value_set_search_results.jsp");
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
        <%@ include file="/pages/templates/content-header-resolvedvalueset.jsp" %>
        
<%

String valueSetSearch_requestContextPath = request.getContextPath();

System.out.println("valueSetSearch_requestContextPath: " + valueSetSearch_requestContextPath);

String message = (String) request.getSession().getAttribute("message");  
request.getSession().removeAttribute("message");  

String vsd_uri = (String) request.getSession().getAttribute("vsd_uri");
if (vsd_uri == null) {
    vsd_uri = (String) request.getParameter("vsd_uri");
}


request.getSession().setAttribute("vsd_uri", vsd_uri);


Vector coding_scheme_ref_vec = DataUtils.getCodingSchemeReferencesInValueSetDefinition(vsd_uri);
String checked = "";

%>
        <div class="pagecontent">
          <a name="evs-content" id="evs-content"></a>
          <!--
          <%@ include file="/pages/templates/navigationTabs.jsp"%>
          -->
          <div class="tabTableContentContainer">
          
          
          <table>
            <tr>
            <td class="texttitle-blue">Resolve Value Set:&nbsp;<%=vsd_uri%></td>
            </tr>

            <% if (message != null)  { 
                request.getSession().removeAttribute("message");
            %>
            
        <tr class="textbodyred"><td>
      <p class="textbodyred">&nbsp;<%=message%></p>
        </td></tr>
            <% } %>

            <tr class="textbody"><td>

 <h:form id="resolveValueSetForm" styleClass="search-form">            
               
              <table class="dataTable" summary="" cellpadding="3" cellspacing="0" border="0" width="100%">
                <th class="dataTableHeader" scope="col" align="left">&nbsp;</th>
                <th class="dataTableHeader" scope="col" align="left">Coding Scheme</th>
                <th class="dataTableHeader" scope="col" align="left">Version</th>
                <th class="dataTableHeader" scope="col" align="left">Tag</th>
<%
if (coding_scheme_ref_vec != null) {
            for (int i=0; i<coding_scheme_ref_vec.size(); i++) {
            
		    String coding_scheme_ref_str = (String) coding_scheme_ref_vec.elementAt(i);
		    String coding_scheme_name_version = coding_scheme_ref_str;
		    
		    Vector u = DataUtils.parseData(coding_scheme_ref_str);
		    String cs_name = (String) u.elementAt(0);
		    String cs_version = (String) u.elementAt(1);
		    String cs_tag = DataUtils.getVocabularyVersionTag(cs_name, cs_version);
		    
		    if (coding_scheme_ref_vec.size() == 1) {
		        checked = "checked";
		    } else if (cs_tag.compareToIgnoreCase("PRODUCTION") == 0) {
		        checked = "checked";
		    }
		    
        
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

		<td>
		     <input type=checkbox name="coding_scheme_ref" value="<%=coding_scheme_name_version%>" <%=checked%> >&nbsp;</input>
		</td>
		
		      <td class="dataCellText">
			 <%=cs_name%>
		      </td>
		      <td class="dataCellText">
			 <%=cs_version%>
		      </td>
		      <td class="dataCellText">
			 <%=cs_tag%>
		      </td>		      

        
		      </tr>
              
             <%
                }
} else {
%>
<tr><td>
<p class="textbodyred">&nbsp;WARNING: Unable to retrieve coding scheme reference data from the server.</p>
</td></tr>
<%
}
             %>                 
                  
              </table>

                  <tr><td>
                    <h:commandButton id="continue_resolve" value="continue_resolve" action="#{valueSetBean.continueResolveValueSetAction}"
                      onclick="javascript:cursor_wait();"
                      image="#{valueSetSearch_requestContextPath}/images/continue.gif"
                      alt="Resolve"
                      tabindex="2">
                    </h:commandButton>
                  </td></tr>
                  
              <input type="hidden" name="vsd_uri" id="vsd_uri" value="<%=vsd_uri%>">    
              <input type="hidden" name="referer" id="referer" value="<%=HTTPUtils.getRefererParmEncode(request)%>">
</h:form>
            
          </td></tr>
        </table>
        </div> <!-- end tabTableContentContainer -->
        <%@ include file="/pages/templates/nciFooter.jsp" %>
      </div>
      <!-- end Page content -->
    </div>
    <div class="mainbox-bottom"><img src="<%=basePath%>/images/mainbox-bottom.gif" width="745" height="5" alt="Mainbox Bottom" /></div>
    <!-- end Main box -->
  </div>
</f:view>
</body>
</html>