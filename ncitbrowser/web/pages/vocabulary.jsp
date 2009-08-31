<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ page contentType="text/html;charset=windows-1252"%>
<%@ page import="java.util.Vector"%>
<%@ page import="org.LexGrid.concepts.Concept" %>
<%@ page import="gov.nih.nci.evs.browser.utils.DataUtils" %>
<%@ page import="gov.nih.nci.evs.browser.utils.MetadataUtils" %>
<%@ page import="gov.nih.nci.evs.browser.properties.NCItBrowserProperties" %>
<%@ page import="gov.nih.nci.evs.browser.bean.MetadataElement" %>


<%
  String ncit_build_info = new DataUtils().getNCITBuildInfo();
%>
<!-- Build info: <%=ncit_build_info%> -->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>NCI Thesaurus</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
  <link rel="stylesheet" type="text/css" href="<%= request.getContextPath() %>/css/styleSheet.css" />
  <script type="text/javascript" src="<%= request.getContextPath() %>/js/script.js"></script>
  <script type="text/javascript" src="<%= request.getContextPath() %>/js/search.js"></script>
  <script type="text/javascript" src="<%= request.getContextPath() %>/js/dropdown.js"></script>
</head>
<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">

<f:view>

<%    
String menubar_scheme = null;
String menubar_scheme0 = null;
String menubar_version = null;
String download_site = null; 
String voc_description = null;
String voc_version = null;
Vector v = null;


Vector metadata_names = new Vector();
List metadataElementList = NCItBrowserProperties.getMetadataElementList();
for (int i=0; i<metadataElementList.size(); i++) {
    MetadataElement ele = (MetadataElement) metadataElementList.get(i);
    metadata_names.add(ele.getName());
}

%>

  <%@ include file="/pages/templates/header.xhtml" %>
  <div class="center-page">
    <%@ include file="/pages/templates/sub-header.xhtml" %>
    <!-- Main box -->
    

    <div id="main-area">
    
        <%
            String dictionary = (String) request.getParameter("dictionary");
            String scheme = (String) request.getParameter("scheme");
            if (scheme == null) {
                scheme = (String) request.getAttribute("scheme");
            }
            String version = (String) request.getParameter("version");
            if (version == null) {
                version = (String) request.getAttribute("version");
            }
            
            
            if (dictionary != null && scheme == null) {
                scheme = dictionary;
                if (version != null) {
                    dictionary = dictionary + " (version" + version + ")";
                    version = version.replaceAll("%20", " ");
                }
            }
 
System.out.println("** scheme: " + scheme);
System.out.println("** version: " + version);
System.out.println("** dictionary: " + dictionary);
 
            if (dictionary != null) dictionary = dictionary.replaceAll("%20", " ");
            if (scheme != null) scheme = scheme.replaceAll("%20", " ");

menubar_scheme = scheme;
menubar_version = version;
menubar_scheme0 = menubar_scheme;


boolean isLicensed = LicenseBean.isLicensed(scheme, version);
System.out.println("** isLicensed: " + isLicensed);

if (isLicensed) {
%>
<P>
Please review the License/Copyright Agreement for <%=scheme%> available <a href="url">here</a>.  
</p>
<P>
If and only if you agree to these terms/conditions, click the Accept button to proceed.   
</p>
<P>
<img src="<%= request.getContextPath() %>/images/selectAll.gif" name="selectAll" alt="selectAll" onClick="checkAll(document.searchTerm.ontology_list)"/>
&nbsp;&nbsp;
<img src="<%= request.getContextPath() %>/images/reset.gif" name="reset" alt="reset" onClick="history.back()" />
</p>

<%
} else {


            if (scheme != null) {
                scheme = scheme.replaceAll("%20", " ");
                request.setAttribute("scheme", scheme);
            }
            if (version != null) {
                version = version.replaceAll("%20", " ");
                request.setAttribute("version", version);
            }
            if (dictionary != null) {
                dictionary = dictionary.replaceAll("%20", " ");
                request.setAttribute("dictionary", dictionary);
            }
            
        %>
        
<!-- Thesaurus, banner search area -->
<div class="bannerarea">
	    <div class="vocabularyName">
		&nbsp;&nbsp;<%=scheme%>
	    </div>

	    <div class="search-globalnav">
		<!-- Search box -->
		<div class="searchbox-top"><img src="<%=basePath%>/images/searchbox-top.gif" width="352" height="2" alt="SearchBox Top" /></div>
		<div class="searchbox"><%@ include file="/pages/templates/searchForm.xhtml" %></div>
		<div class="searchbox-bottom"><img src="<%=basePath%>/images/searchbox-bottom.gif" width="352" height="2" alt="SearchBox Bottom" /></div>
		<!-- end Search box -->
		<!-- Global Navigation -->
		
		
<%		
v = MetadataUtils.getMetadataNameValuePairs(scheme, version, null);
Vector u1 = MetadataUtils.getMetadataValues(v, "description");
voc_description = scheme;
if (u1 != null && u1.size() > 0) {
	voc_description = (String) u1.elementAt(0);
	if (voc_description == null || voc_description.compareTo("") == 0 || voc_description.compareTo("null") == 0) {
	    voc_description = "";
	}
}
Vector u2 = MetadataUtils.getMetadataValues(v, "version");
voc_version = "";
if (u2 != null && u2.size() > 0) {
	voc_version = (String) u2.elementAt(0);
}
Vector u3 = MetadataUtils.getMetadataValues(v, "download_url");
if (u3 != null && u3.size() > 0) {
	download_site = (String) u3.elementAt(0);
}


if (menubar_scheme != null) {
menubar_scheme = menubar_scheme.replaceAll(" ", "%20");
}
if (menubar_version != null) {
menubar_version = menubar_version.replaceAll(" ", "%20");
}

%>

<div class="global-nav">
<%
if (menubar_version == null) {
%>
  <a href="<%= request.getContextPath() %>/pages/vocabulary_home.jsf?dictionary=<%=dictionary%>&scheme=<%=menubar_scheme%>">Home</a>
<%
} else {
%>
  <a href="<%= request.getContextPath() %>/pages/vocabulary_home.jsf?dictionary=<%=dictionary%>&scheme=<%=menubar_scheme%>&version=<%=menubar_version%>">Home</a>
<%
}
  if (download_site != null) {
%>  
  | <a href="#" onclick="javascript:window.open('<%=download_site%>', '_blank','top=100, left=100, height=740, width=680, status=no, menubar=no, resizable=yes, scrollbars=yes, toolbar=no, location=no, directories=no');">
    Download
  </a>
<%  
  }
%> 
  
  | <a href="#" onclick="javascript:window.open('<%=request.getContextPath() %>/pages/hierarchy.jsf?dictionary=<%=menubar_scheme%>&version=<%=menubar_version%>', '_blank','top=100, left=100, height=740, width=680, status=no, menubar=no, resizable=yes, scrollbars=yes, toolbar=no, location=no, directories=no');">
    View Hierarchy
  </a>
  
<%  
  if (menubar_scheme0.compareTo("NCI Thesaurus") == 0) {
%>  
  | <a href="<%= request.getContextPath() %>/pages/subset.jsf">Subsets</a>
<%  
  }
%>   
  
  | <a href="<%= request.getContextPath() %>/pages/help.jsf">Help</a>
</div>		
		
		    
		    
		    
		<!-- end Global Navigation -->
	    </div>
  
</div>
<!-- end Thesaurus, banner search area -->



<!-- Quick links bar -->
<%@ include file="/pages/templates/quickLink.xhtml" %>
<!-- end Quick links bar -->


<%@ include file="/pages/templates/welcome2.html" %>

      
      <!-- Page content -->
    <%
    
      if (v == null || v.size() == 0) {
     %> 
          <i>Metadata not found.</i>
     <%     
      } else {
      %>
          <i>&nbsp;</i>
	  <table class="dataTable">
	    <%
	      int n1 = 0;
	      for (int i=0; i<v.size(); i++) {
		String s = (String) v.get(i);
		Vector ret_vec = DataUtils.parseData(s, "|");
		String meta_prop_name = (String) ret_vec.elementAt(0);
		if (!metadata_names.contains(meta_prop_name)) {
			String meta_prop_value = (String) ret_vec.elementAt(1);
			if (meta_prop_value.startsWith("ftp:") || meta_prop_value.startsWith("http:")) {
			    meta_prop_value = DataUtils.getDownloadLink(meta_prop_value);
			}

			if (n1 % 2 == 0) {
			  %>
			    <tr class="dataRowDark">
			  <%
			} else {
			  %>
			    <tr class="dataRowLight">
			  <%
			}
			n1++;
			%>
			      <td><%=meta_prop_name%></td>
			      <td><%=meta_prop_value%></td>
			    </tr>
		      <%
		      }
	        }
		%>
	  </table>              
      <%    
      }
      %>
      
 
 
      <%    
      }
      %> 
      
      
      <%@ include file="/pages/templates/nciFooter.html" %>

      <!-- end Page content -->
    </div>
    <div class="mainbox-bottom"><img src="<%=basePath%>/images/mainbox-bottom.gif" width="745" height="5" alt="Mainbox Bottom" /></div>
    <!-- end Main box -->
  </div>
</f:view>

</body>
</html>