<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>
<%@taglib uri="http://srs.slac.stanford.edu/GroupManager" prefix="gm"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display"%>
<%@taglib uri="http://srs.slac.stanford.edu/displaytag" prefix="displayutils"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="tg"%>

<!DOCTYPE html>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <script src="js/jquery-1.11.1.min.js"></script>
        <script src="js/jquery.validate.min.js"></script>
        <link rel="stylesheet" href="css/pubstyles.css">
        <title>LSST DESC Publications Board</title>
    </head>
<body>
    
    <c:if test="${!(gm:isUserInGroup(pageContext,'GroupManagerAdmin') || gm:isUserInGroup(pageContext,'lsst-desc-members'))}">
        <c:redirect url="noPermission.jsp?errmsg=7"/>
    </c:if>  
    
    <tg:underConstruction/>
    
    <p/>
     <c:set var="convenLink" value="http://srs.slac.stanford.edu/GroupManager/exp/LSST-DESC/protected/group.jsp?name="/>
        
        <sql:query var="swgs">
            select id, name, profile_group_name as pgn, convener_group_name as cgn from descpub_swg 
            order by name
        </sql:query>
            
        <sql:query var="papers">
            select paperid, project_id, createdate, modifydate, pubtype, title from (select * from descpub_publication order by createdate desc) where rownum <= 10
        </sql:query>
             
        <c:if test="${swgs.rowCount > 0}">
            <display:table class="datatable"  id="Row" name="${swgs.rows}">
                <display:column title="Working Groups (WGs)" href="show_swg.jsp" paramId="swgid" property="name" paramProperty="id" sortable="true" headerClass="sortable" style="text-align:left;"/>
                <display:column title="Number of Projects (can be in multiple WGs)" style="text-align:left;">
                    <sql:query var="prow">
                    select count(project_id) tot from descpub_project_swgs where swg_id = ?
                    <sql:param value="${Row.id}"/>
                    </sql:query>
                    <c:if test="${prow.rows[0].tot > 0}">
                        ${prow.rows[0].tot}
                    </c:if>
                </display:column> 
            </display:table>
        </c:if>  
        <p></p>
     

        <c:if test="${papers.rowCount > 0}">
             <p id="pagelabel">Most recent Documents</p> 
            <display:table class="datatable" id="Line" name="${papers.rows}">
                <display:column title="ID" style="text-align:left;" sortable="true" headerClass="sortable" >
                   <a href="show_pub.jsp?paperid=${Line.paperid}">DESC-${Line.paperid} </a>
                </display:column>
                <display:column property="title" title="Title" style="text-align:left;" sortable="true" headerClass="sortable"/>
                <display:column property="pubtype" title="Doc Type" style="text-align:left;" sortable="true" headerClass="sortable"/>
                <display:column property="createdate" style="text-align:left;" title="Created" sortable="true" headerClass="sortable"/>
                <display:column property="modifydate" style="text-align:left;" title="Last Modified" sortable="true" headerClass="sortable"/>
                <display:column title="Project" style="text-align:left;" sortable="true" headerClass="sortable">
                  ${Line.project_id}">Project-${Line.project_id}
                </display:column>
            </display:table>
        </c:if>        
    
        <c:if test="${pubs.rowCount > 0}">
           <display:table class="datatable" id="irow" name="${pubs.rows}"/>
        </c:if>
                    
    </body>

</html>
