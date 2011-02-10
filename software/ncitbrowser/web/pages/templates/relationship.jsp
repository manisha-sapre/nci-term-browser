
<%
  if (type.compareTo("relationship") == 0 || type.compareTo("all") == 0)
  {


Entity concept_curr = (Entity) request.getSession().getAttribute("concept");
String scheme_curr = (String) request.getSession().getAttribute("dictionary");
if (scheme_curr == null) {
scheme_curr = (String) request.getParameter("dictionary");
}

String version_curr = (String) request.getSession().getAttribute("version");
System.out.println("(*) relationship.jsp version_curr: " + version_curr);
String version_parameter = "";
if (version_curr != null && ! version_curr.equalsIgnoreCase("null"))
    version_parameter = "&version=" + version_curr;


boolean isMapping = DataUtils.isMapping(scheme_curr, version_curr);
String code_curr = (String) request.getSession().getAttribute("code");

    String rel_display_name = DataUtils.getMetadataValue(scheme_curr, version_curr, "display_name");
    if (rel_display_name == null) rel_display_name = DataUtils.getLocalName(scheme_curr);

    if (code_curr == null) {
        code_curr = (String) request.getParameter("code");
    }

    HashMap hmap = (HashMap) request.getSession().getAttribute("RelationshipHashMap");
    if (hmap == null) {
      DataUtils util = new DataUtils();
      hmap = util.getRelationshipHashMap(scheme_curr, version_curr, code_curr);
    }

    if (hmap != null) {

    request.getSession().setAttribute("RelationshipHashMap", hmap);

    ArrayList superconcepts = (ArrayList) hmap.get(DataUtils.TYPE_SUPERCONCEPT);
    ArrayList subconcepts = (ArrayList) hmap.get(DataUtils.TYPE_SUBCONCEPT);
    ArrayList roles = (ArrayList) hmap.get(DataUtils.TYPE_ROLE);
    ArrayList associations = (ArrayList) hmap.get(DataUtils.TYPE_ASSOCIATION);

    ArrayList inverse_roles = (ArrayList) hmap.get(DataUtils.TYPE_INVERSE_ROLE);
    ArrayList inverse_associations = (ArrayList) hmap.get(DataUtils.TYPE_INVERSE_ASSOCIATION);

    ArrayList concepts = null;
    String label = "";
    String rel = "";
    String score = "";
    scheme_curr = scheme_curr.replaceAll(" ", "%20");

%>
  <table border="0" width="708px">
    <tr>
      <td class="textsubtitle-blue" align="left">Relationships with other <%=rel_display_name%> Concepts</td>
      <td align="right" class="texttitle-blue-rightJust">
        <h:form>
          <h:commandLink action="#{CartActionBean.addToCart}" value="Add to Cart">
            <f:setPropertyActionListener target="#{CartActionBean.entity}" value="concept" />
            <f:setPropertyActionListener target="#{CartActionBean.codingScheme}" value="dictionary" />
          </h:commandLink>
        </h:form>
      </td>
    </tr>
  </table>
<%
 if (!isMapping) {
%>

  <p>
    <%

      label = "Parent Concepts:";
      concepts = superconcepts;
      if (concepts == null || concepts.size() <= 0)
      {
    %>
        <b><%=label%></b> <i>(none)</i>
    <%
      } else if (concepts != null && concepts.size() == 1) {
          String s = (String) concepts.get(0);
          Vector ret_vec = DataUtils.parseData(s, "|");
          String cName = (String) ret_vec.elementAt(0);
          String cCode = (String) ret_vec.elementAt(1);
    %>
          <b><%=label%></b>
          <a href="<%= request.getContextPath() %>/ConceptReport.jsp?dictionary=<%=scheme_curr%><%=version_parameter%>&code=<%=cCode%>">
            <%=cName%>
          </a>
    <%
      } else if (concepts != null) {
    %>
        <b><%=label%></b>
        <table class="dataTable">
    <%
        for (int i=0; i<concepts.size(); i++) {
          String s = (String) concepts.get(i);
          Vector ret_vec = DataUtils.parseData(s, "|");
          String cName = (String) ret_vec.elementAt(0);
          String cCode = (String) ret_vec.elementAt(1);
          String rowColor = (i%2 == 0) ? "dataRowDark" : "dataRowLight";
    %>
          <tr class="<%=rowColor%>">
            <td class="dataCellText">
              <a href="<%= request.getContextPath() %>/ConceptReport.jsp?dictionary=<%=scheme_curr%><%=version_parameter%>&code=<%=cCode%>">
                <%=cName%>
              </a>
            </td>
          </tr>
    <%
        }
    %>
        </table>
    <%
      }
    %>
  </p>

  <p>
    <%
      label = "Child Concepts:";
      concepts = subconcepts;
      if (concepts == null || concepts.size() <= 0)
      {
    %>
        <b><%=label%></b> <i>(none)</i>
    <%
      } else if (concepts != null && concepts.size() == 1) {
          String s = (String) concepts.get(0);
          Vector ret_vec = DataUtils.parseData(s, "|");
          String cName = (String) ret_vec.elementAt(0);
          String cCode = (String) ret_vec.elementAt(1);
    %>
          <b><%=label%></b>
          <a href="<%= request.getContextPath() %>/ConceptReport.jsp?dictionary=<%=scheme_curr%><%=version_parameter%>&code=<%=cCode%>">
            <%=cName%>
          </a>
    <%
      } else if (concepts != null) {
    %>
        <b><%=label%></b>
        <table class="dataTable">
    <%
        for (int i=0; i<concepts.size(); i++) {
          String s = (String) concepts.get(i);
          Vector ret_vec = DataUtils.parseData(s, "|");
          String cName = (String) ret_vec.elementAt(0);
          String cCode = (String) ret_vec.elementAt(1);
          String rowColor = (i%2 == 0) ? "dataRowDark" : "dataRowLight";
    %>
          <tr class="<%=rowColor%>">
            <td class="dataCellText">
              <a href="<%= request.getContextPath() %>/ConceptReport.jsp?dictionary=<%=scheme_curr%><%=version_parameter%>&code=<%=cCode%>">
                <%=cName%>
              </a>
            </td>
          </tr>
    <%
        }
    %>
        </table>
    <%
      }
    %>
  </p>



  <p>
  <%
     if (roles != null && roles.size() > 0)
     {
  %>
       <b>Role Relationships:</b>

  <br/>
  <i>(Roles are true for current concept and descendants, may be inherited from parent(s).)</i>
  <table class="dataTable">

 <%
 if (isMapping) {
 %>
     <th class="dataTableHeader" scope="col" align="left">Relationship</th>
     <th class="dataTableHeader" scope="col" align="left">Name</th>
     <th class="dataTableHeader" scope="col" align="left">Code</th>
     <th class="dataTableHeader" scope="col" align="left">REL</th>
     <th class="dataTableHeader" scope="col" align="left">Map Rank</th>
 <%
 }
 %>


    <%
      int n1 = 0;
      for (int i=0; i<roles.size(); i++) {
        String s = (String) roles.get(i);
        Vector ret_vec = DataUtils.parseData(s, "|");
        String role_name = (String) ret_vec.elementAt(0);
        String target_concept_name = (String) ret_vec.elementAt(1);
        String target_concept_code = (String) ret_vec.elementAt(2);
        String target_coding_scheme_name = (String) ret_vec.elementAt(3);
        String qualifiers = null;
  rel = null;
  score = null;

  if (isMapping) {
      qualifiers = (String) ret_vec.elementAt(4);
      System.out.println(qualifiers);
      Vector v = DataUtils.parseData(qualifiers, "$");
      String rel_str = (String) v.elementAt(0);
      int m1 = rel_str.indexOf(":");
      rel = rel_str.substring(m1+1, rel_str.length());
      String score_str = (String) v.elementAt(1);
      int m2 = score_str.indexOf(":");
      score = score_str.substring(m2+1, score_str.length());
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
              <td><%=role_name%></td>
              <td>
                <a href="<%= request.getContextPath() %>/ConceptReport.jsp?dictionary=<%=target_coding_scheme_name%><%=version_parameter%>&code=<%=target_concept_code%>">
                  <%=target_concept_name%>
                </a>
              </td>


              <%
              if (isMapping) {
              %>
              <td>
                <a href="<%= request.getContextPath() %>/ConceptReport.jsp?dictionary=<%=target_coding_scheme_name%><%=version_parameter%>&code=<%=target_concept_code%>">
                  <%=target_concept_code%>
                </a>
              </td>
              <td><%=rel%></td>
              <td><%=score%></td>
              <%
              }
              %>


            </tr>
      <%
      }
      %>
  </table>
</p>
<p>

  <%
     } else if (roles == null || roles.size() == 0) {
  %>
       <b>Role Relationships: </b><i>(none)</i>
  <%
     }
  %>



<%
 }
%>


<p>
<%
  if (associations != null && associations.size() > 0) {
%>
    <b>Associations:</b>
<br/>
<i>(Associations are true only for the current concept.)</i>
<table class="dataTable">


<%
 if (isMapping) {
 %>
     <th class="dataTableHeader" scope="col" align="left">Relationship</th>
     <th class="dataTableHeader" scope="col" align="left">Name</th>
     <th class="dataTableHeader" scope="col" align="left">Code</th>
     <th class="dataTableHeader" scope="col" align="left">Namespace</th>
     <th class="dataTableHeader" scope="col" align="left">REL</th>
     <th class="dataTableHeader" scope="col" align="left">Map Rank</th>
 <%
 }
 %>


  <%
    int n2 = 0;

    for (int i=0; i<associations.size(); i++) {
      String s = (String) associations.get(i);
      Vector ret_vec = DataUtils.parseData(s, "|");
      String role_name = (String) ret_vec.elementAt(0);
      String target_concept_name = (String) ret_vec.elementAt(1);
      String target_concept_code = (String) ret_vec.elementAt(2);
      String target_coding_scheme_name = (String) ret_vec.elementAt(3);
      String target_namespace = null;

  String qualifiers = null;
  rel = null;
  score = null;

  if (isMapping) {
      qualifiers = (String) ret_vec.elementAt(4);
      System.out.println(qualifiers);
      Vector v = DataUtils.parseData(qualifiers, "$");
      String rel_str = (String) v.elementAt(0);
      int m1 = rel_str.indexOf(":");
      rel = rel_str.substring(m1+1, rel_str.length());
      String score_str = (String) v.elementAt(1);
      int m2 = score_str.indexOf(":");
      score = score_str.substring(m2+1, score_str.length());

      target_namespace = (String) ret_vec.elementAt(5);
  }

      if (n2 % 2 == 0) {
        %>
            <tr class="dataRowDark">
        <%
        } else {
        %>
            <tr class="dataRowLight">
        <%
        }
        n2++;
        %>
              <td><%=role_name%></td>
              <td>
              <%
              if (!DataUtils.isNonConcept2ConceptAssociation(role_name)) {
              %>
                <a href="<%= request.getContextPath() %>/ConceptReport.jsp?dictionary=<%=target_coding_scheme_name%><%=version_parameter%>&code=<%=target_concept_code%>">
                  <%=target_concept_name%>
                </a>
              <%
              } else {
              %>
                <%=target_concept_name%>
              <%
              }
              %>
              </td>
              <%
              if (isMapping) {
              %>
              <td>
                <a href="<%= request.getContextPath() %>/ConceptReport.jsp?dictionary=<%=target_coding_scheme_name%><%=version_parameter%>&code=<%=target_concept_code%>">
                  <%=target_concept_code%>
                </a>
              </td>
              <td><%=target_namespace%></td>
              <td><%=rel%></td>
              <td><%=score%></td>
              <%
              }
              %>

            </tr>
        <%
        }
        %>
 </table>
</p>

<%
  } else if (associations == null || associations.size() == 0) {
    %>
    <b>Associations: </b><i>(none)</i>
    <%
  }
%>


  <p>
  <%
     String display_inverse_relationships_metadata_value = DataUtils.getMetadataValue(scheme_curr, version_curr, "display_inverse_relationships");
     boolean display_inverse_relationships = true;
     if (display_inverse_relationships_metadata_value != null && display_inverse_relationships_metadata_value.compareToIgnoreCase("false") == 0) {
         display_inverse_relationships = false;
     }


if (!isMapping) {


     if (inverse_roles != null && inverse_roles.size() > 0 && display_inverse_relationships)
     {
  %>
       <b>Inverse Role Relationships:</b>

  <br/>
  <i>(Roles are true for current concept and descendants, may be inherited from parent(s).)</i>
  <table class="dataTable">


  <%
   if (isMapping) {
   %>
       <th class="dataTableHeader" scope="col" align="left">Name</th>
       <th class="dataTableHeader" scope="col" align="left">Code</th>
       <th class="dataTableHeader" scope="col" align="left">Relationship</th>
       <th class="dataTableHeader" scope="col" align="left">REL</th>
       <th class="dataTableHeader" scope="col" align="left">Map Rank</th>
   <%
   }
 %>


    <%
      int n1 = 0;
      for (int i=0; i<inverse_roles.size(); i++) {
        String s = (String) inverse_roles.get(i);
        Vector ret_vec = DataUtils.parseData(s, "|");
        String role_name = (String) ret_vec.elementAt(0);
        String target_concept_name = (String) ret_vec.elementAt(1);
        String target_concept_code = (String) ret_vec.elementAt(2);
        String target_coding_scheme_name = (String) ret_vec.elementAt(3);

  String qualifiers = null;
  rel = null;
  score = null;

  if (isMapping) {
      qualifiers = (String) ret_vec.elementAt(4);
      System.out.println(qualifiers);
      Vector v = DataUtils.parseData(qualifiers, "$");
      String rel_str = (String) v.elementAt(0);
      int m1 = rel_str.indexOf(":");
      rel = rel_str.substring(m1+1, rel_str.length());
      String score_str = (String) v.elementAt(1);
      int m2 = score_str.indexOf(":");
      score = score_str.substring(m2+1, score_str.length());
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
              <td>
              <%
              //if (role_name.compareTo("domain") != 0 && role_name.compareTo("range") != 0) {
              if (!DataUtils.isNonConcept2ConceptAssociation(role_name)) {
              %>
                <a href="<%= request.getContextPath() %>/ConceptReport.jsp?dictionary=<%=target_coding_scheme_name%><%=version_parameter%>&code=<%=target_concept_code%>">
                  <%=target_concept_name%>
                </a>
              <%
              } else {
              %>
                <%=target_concept_name%>
              <%
              }
              %>
              </td>


              <%
              if (isMapping) {
              %>
              <td>
                <a href="<%= request.getContextPath() %>/ConceptReport.jsp?dictionary=<%=target_coding_scheme_name%><%=version_parameter%>&code=<%=target_concept_code%>">
                  <%=target_concept_code%>
                </a>
              </td>
              <%
              }
              %>

              <td><%=role_name%></td>
              <%
              if (isMapping) {
              %>

              <td><%=rel%></td>
              <td><%=score%></td>
              <%
              }
              %>

           </tr>
      <%
      }
      %>
  </table>
</p>
<p>

  <%
     } else if ((inverse_roles == null || inverse_roles.size() == 0) && display_inverse_relationships) {
  %>
       <b>Inverse Role Relationships: </b><i>(none)</i>
  <%
     }
  %>


<%
 }
%>


<p>
<%
  if (inverse_associations != null && inverse_associations.size() > 0 && display_inverse_relationships) {
%>
    <b>Inverse Associations:</b>
<br/>
<i>(Associations are true only for the current concept.)</i>
<table class="dataTable">

  <%
   if (isMapping) {
   %>
       <th class="dataTableHeader" scope="col" align="left">Name</th>
       <th class="dataTableHeader" scope="col" align="left">Code</th>
       <th class="dataTableHeader" scope="col" align="left">Namespace</th>
       <th class="dataTableHeader" scope="col" align="left">Relationship</th>
       <th class="dataTableHeader" scope="col" align="left">REL</th>
       <th class="dataTableHeader" scope="col" align="left">Map Rank</th>
   <%
   }
 %>


  <%
    int n2 = 0;

    for (int i=0; i<inverse_associations.size(); i++) {
      String s = (String) inverse_associations.get(i);
      Vector ret_vec = DataUtils.parseData(s, "|");
      String role_name = (String) ret_vec.elementAt(0);
      String target_concept_name = (String) ret_vec.elementAt(1);
      String target_concept_code = (String) ret_vec.elementAt(2);
      String target_coding_scheme_name = (String) ret_vec.elementAt(3);
      String target_namespace = null;
  String qualifiers = null;
  rel = null;
  score = null;

  if (isMapping) {
      if (ret_vec.size() > 4) {
        qualifiers = (String) ret_vec.elementAt(4);
        System.out.println(qualifiers);
        Vector v = DataUtils.parseData(qualifiers, "$");
        String rel_str = (String) v.elementAt(0);
        int m1 = rel_str.indexOf(":");
        rel = rel_str.substring(m1+1, rel_str.length());
        String score_str = (String) v.elementAt(1);
        int m2 = score_str.indexOf(":");
        score = score_str.substring(m2+1, score_str.length());
      }
      if (ret_vec.size() > 5) {
          target_namespace = (String) ret_vec.elementAt(5);
      }
  }

      if (n2 % 2 == 0) {
        %>
            <tr class="dataRowDark">
        <%
        } else {
        %>
            <tr class="dataRowLight">
        <%
        }
        n2++;
        %>
              <td>

              <%
              if (role_name.compareTo("domain") != 0 && role_name.compareTo("range") != 0) {
              %>

                <a href="<%= request.getContextPath() %>/ConceptReport.jsp?dictionary=<%=target_coding_scheme_name%><%=version_parameter%>&code=<%=target_concept_code%>">
                  <%=target_concept_name%>
                </a>
              <%
              } else {
              %>
                <%=target_concept_name%>
              <%
              }
              %>
              </td>

              <%
              if (isMapping) {
              %>
              <td>
                <a href="<%= request.getContextPath() %>/ConceptReport.jsp?dictionary=<%=target_coding_scheme_name%><%=version_parameter%>&code=<%=target_concept_code%>">
                  <%=target_concept_code%>
                </a>
              </td>
              <td><%=target_namespace%></td>
              <%
              }
              %>

              <td><%=role_name%></td>
              <%
              if (isMapping) {
              %>
              <td><%=rel%></td>
              <td><%=score%></td>
              <%
              }
              %>

            </tr>
        <%
        }
        %>
 </table>
</p>

<%
  } else if ((inverse_associations == null || inverse_associations.size() == 0) && display_inverse_relationships) {
    %>
    <b>Inverse Associations: </b><i>(none)</i>
    <%
  }
%>



<%
}

%>


<%
 if (!isMapping) {

        Vector mapping_uri_version_vec = DataUtils.getMappingCodingSchemesEntityParticipatesIn(code_curr, null);
        if (mapping_uri_version_vec != null && mapping_uri_version_vec.size() > 0) {
%>

<p>
    <b>Mapping Relationships:</b>
<br/>
<table class="dataTable">
<%

  for(int lcv=0; lcv<mapping_uri_version_vec.size(); lcv++) {
       String mapping_uri_version = (String) mapping_uri_version_vec.elementAt(lcv);
       Vector ret_vec = DataUtils.parseData(mapping_uri_version, "|");
       String mapping_cs_uri = (String) ret_vec.elementAt(0);
       String mapping_cs_version = (String) ret_vec.elementAt(1);

       String mapping_cs_name = DataUtils.uri2CodingSchemeName(mapping_cs_uri);

%>
       <tr>
         <td>
         <%=mapping_cs_uri%>&nbsp;(<%=mapping_cs_version%>)&nbsp;
                <a href="<%= request.getContextPath() %>/ConceptReport.jsp?dictionary=<%=mapping_cs_name%><%=version_parameter%>&code=<%=code_curr%>&type=relationship">
                   <i class="textbodyred">View Mapping</i>
                </a>
         </td>
             </tr>
<%

  }

%>


</table>
</p>

<%
}
}
}
%>

