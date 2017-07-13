<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://srs.slac.stanford.edu/displaytag" prefix="displayutils" %>
<%@taglib prefix="f" uri="http://lsstdesc.org/functions" %>
<!DOCTYPE html>

<html>
    <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
      <link rel="stylesheet" href="css/site-demos.css">
      <title>DESC Publication Board</title>
    </head>
    <body>
        
        <%--
        <a href="show_swg.jsp">SWGs</a><br/>
        <a href="show_projects.jsp">Projects</a><br/>
        Publications --%>
        
       
        
        <c:choose>
            <c:when test="${empty param}">
                <a href="index.jsp?showSWG=swgs">SWGs</a><br/>
                <a href="index.jsp?showPROJ=projects">Projects</a><br/>
                <a href="index.jsp?showPUB=publications">Publications</a><br/>
            </c:when>
            <c:when test="${param.showSWG=='swgs'}">
                <sql:query var="swgs" dataSource="jdbc/config-dev">
                    select id, name, email, profile_group_name from lsstdesc_swg order by id
                </sql:query>
                <c:set var="starturl" value="http://srs.slac.stanford.edu/GroupManager/exp/LSST-DESC/protected/group.jsp?"/>
                <a href="swg.jsp?createswg=true">create swg</a><br/>
                    
                <display:table class="datatable" id="Row" name="${swgs.rows}">
                   <display:column title="Science Working Groups" sortable="true" headerClass="sortable">
                       <a href="show_swg.jsp?name=${Row.name}">${Row.name}</a>
                   </display:column>
                   <display:column title="Email List" sortable="true" headerClass="sortable">
                       <a href="mailto:${Row.email}">${Row.email}</a>
                   </display:column>
                   <display:column title="Conveners" sortable="true" headerClass="sortable">
                       <a href="${starturl}${Row.name}">${Row.name}</a>
                   </display:column>
                </display:table>
            </c:when>
            <c:when test="${param.showPROJ=='projects'}">
                <sql:query var="projects" dataSource="jdbc/config-dev">
                    select keyprj, status, title, abstract as abs, state, created, comments from lsstdesc_project order by id
                </sql:query>

                <display:table class="datatable" id="Row" name="${projects.rows}">
                    <display:column title="Key Project" sortable="true" headerClass="sortable">
                    ${Row.keyprj}
                    </display:column>
                    <display:column title="Title" sortable="true" headerClass="sortable">
                    ${Row.title}
                    </display:column>
                    <display:column title="Abstract" sortable="true" headerClass="sortable">
                    ${Row.abs}
                    </display:column>
                    <display:column title="Create Date" sortable="true" headerClass="sortable">
                    ${Row.created}
                    </display:column>
                    <display:column title="Status" sortable="true" headerClass="sortable">
                    ${Row.status}
                    </display:column>
                    <display:column title="State" sortable="true" headerClass="sortable">
                    ${Row.state}
                    </display:column>
                </display:table>
            </c:when>
            <c:when test="${param.showPUB=='publications'}">
                <sql:query var="pubs" dataSource="jdbc/config-dev">
                    select id,state,title,journal,abstract abs, added,builder_eligible,comments,keypub,cwr_end_date,assigned_pb_reader,cwr_comments,arxiv,telecon,journal_review,published_reference,project_id from lsstdesc_publication order by id
                </sql:query>
                    
                <display:table class="datatable" id="Row" name="${pubs.rows}">
                    <display:column title="Title" sortable="true" headerClass="sortable">
                      ${Row.title}
                    </display:column>
                    <display:column title="Key Project" sortable="true" headerClass="sortable">
                      ${Row.keyprj}
                    </display:column>
                    <display:column title="Abstract" sortable="true" headerClass="sortable">
                      ${Row.abs}
                    </display:column>
                    <display:column title="Date Added" sortable="true" headerClass="sortable">
                      ${Row.added}
                    </display:column>
                    <display:column title="Builder Eligible" sortable="true" headerClass="sortable">
                      ${Row.builder_eligible}
                    </display:column>
                    <display:column title="Comments" sortable="true" headerClass="sortable">
                       ${Row.comments}
                    </display:column>
                    <display:column title="Key Publication" sortable="true" headerClass="sortable">
                      ${Row.keypub}
                    </display:column>
                    <display:column title="CWR End Date" sortable="true" headerClass="sortable">
                      ${Row.cwr_end_date}
                    </display:column>
                </display:table>
            </c:when>
        </c:choose>
        
    </body>
</html>
        