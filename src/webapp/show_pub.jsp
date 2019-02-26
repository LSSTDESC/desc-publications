<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>

<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib uri="http://srs.slac.stanford.edu/displaytag" prefix="displayutils" %>
<%@taglib uri="http://srs.slac.stanford.edu/utils" prefix="utils"%>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>
<%@taglib tagdir="/WEB-INF/tags" prefix="tg"%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="css/pubstyles.css">
    </head>
    <body>
        
        <tg:underConstruction/>
        
        <fmt:setTimeZone value="UTC"/>  
        <c:if test="${!empty msg}">
            <p id="pagelabel">${msg}</p> 
        </c:if>
         
        <c:if test="${!gm:isUserInGroup(pageContext,'lsst-desc-members')}">  
            <c:redirect url="noPermission.jsp?errmsg=7"/>
        </c:if>
            
        <sql:query var="pnum">
            select project_id from descpub_publication where paperid = ?
            <sql:param value="${param.paperid}"/>
        </sql:query>
        <c:set var="dtype" value="${pnum.rows[0].pubtype}"/>
        <c:set var="projid" value="${pnum.rows[0].project_id}"/> 
        <c:set var="projectGrpName" value="project_${projid}"/>
        <c:set var="paperGrpName" value="paper_${param.paperid}"/>
        <c:set var="paperLeadGrpName" value="paper_leads_${param.paperid}"/>
        <c:set var="paperReviewGrp" value="paper_reviewers_${param.paperid}"/>

        <%-- if project-less document then find its the working group --%>
        <c:if test="${projid == 0}">
            <sql:query var="projectLessWG">
                select wg.name from descpub_publication_swgs s join descpub_swg wg on s.swgid = wg.id
                where s.paperid = ?
                <sql:param value="${param.paperid}"/>
            </sql:query>
        </c:if>
        <c:if test="${projectLessWG.rowCount > 0}">
           <c:set var="projLessWG" value="${projectLessWG.rows[0]['name']}"/>
        </c:if>    
                
       <%-- make mailto list of reviewers, if they exist --%>
        <sql:query var="revGrp">
            select v.first_name, v.last_name, v.email from profile_user v join profile_ug g on v.memidnum=g.memidnum and v.experiment=g.experiment
            where g.group_id = ? and g.experiment = ? and v.email is not null order by v.last_name
            <sql:param value="${paperReviewGrp}"/>
            <sql:param value="${appVariables.experiment}"/>
        </sql:query>
            
        <c:forEach var="rev" items="${revGrp.rows}">
            <c:choose>
                <c:when test="${revGrp.rowCount > 0}">
                    <c:choose>
                    <c:when test="${empty reviewList}">
                       <c:set var="reviewList" value="<a href=mailto:${rev.email}>${rev.first_name} ${rev.last_name}</a>"/>
                       <c:set var="reviewAll" value="${rev.email}"/>
                    </c:when>
                    <c:when test="${! empty reviewList}">
                        <c:set var="reviewList" value="${reviewList}, <a href=mailto:${rev.email}>${rev.first_name} ${rev.last_name}</a>"/>
                        <c:set var="reviewAll" value="${reviewAll}, ${rev.email}"/>
                    </c:when>
                    </c:choose>
                </c:when>
                <c:otherwise>
                    <c:set var="reviewList" value="No reviewers for DESC-${param.paperid}"/>
                </c:otherwise>
            </c:choose>      
        </c:forEach>     
        
        <%-- when testing against dev the tag gm:isUserInGroup won't work because it always checks against the prod db so test separately if user can edit paper.
        canEdit checks if conveners (primary auth) can edit, userCanEdit checks if member of the paper can edit
        
        <c:set var="userCanEdit" value="false"/>   can user edit --%>
        
        <c:set var="selectFields" value=""/> <%-- var to build list of fields per pubtype --%>
        <c:set var="primaryauths" value=""/> 
        
        <%-- Remove this once confirm that isUserInGroup works from Prod only
        <sql:query var="canUser"> --%>
        <%-- check if user is in one of the allowed groups --%>
        <%--
          select memidnum from profile_ug where group_id in (?,?,?) and user_id=? and experiment = ?
          <sql:param value="${paperGrpName}"/>
          <sql:param value="${paperLeadGrpName}"/>
          <sql:param value="${projectGrpName}"/>
          <sql:param value="${userName}"/>
          <sql:param value="${appVariables.experiment}"/>
        </sql:query>
            
        <c:if test="${!empty canUser.rows[0].memidnum}">
             <c:set var="userCanEdit" value="true"/>
        </c:if> --%>
        
        <%-- get the list of fields appropriate for this pubtype  --%>
        <sql:query var="fi">
            select pb.metaid, me.data, me.label, me.datatype, pb.multiplevalues, pb.formposition from descpub_pubtype_fields pb join descpub_metadata me on pb.metaid = me.metaid
            where pb.pubtype in (select pubtype from descpub_publication where paperid = ? )
            order by pb.formposition
            <sql:param value="${param.paperid}"/>
        </sql:query>
            
        <c:forEach var="f" items="${fi.rows}">
            <c:choose>
                <c:when test="${empty selectFields}">
                    <c:set var="selectFields" value="${f.data}"/>
                </c:when>
                <c:when test="${!empty selectFields}">
                    <c:set var="selectFields" value="${selectFields}, ${f.data}"/>
                </c:when>
            </c:choose>
        </c:forEach>      
            
        <%-- add on the pubtype and project_id column names --%>    
        <c:set var="selectFields" value="${selectFields}, pubtype, project_id"/>
            
        <%-- get the publication using the selectList. This list used to control what fields are displayed per pubtype --%> 
        <c:set var="qstr" value="select ${selectFields} from descpub_publication where paperid = ?"/>
        
        <sql:query var="pubs">
            ${qstr}
            <sql:param value="${param.paperid}"/>
        </sql:query> 
        <c:set var="projid" value="${pubs.rows[0].project_id}"/>
        <c:set var="pubtype" value="${fi.rows[0].pubtype}"/> 
         
        
        <%-- second pub query grabs all the details e.g. can_request_authorship 
        <sql:query var="pubDetails">
            select * from descpub_publication where paperid = ?
            <sql:param value="${param.paperid}"/>
        </sql:query> --%>
        
        <%-- get the convener groupname --%>
        <sql:query var="leads">
           select wg.id, wg.convener_group_name from descpub_project_swgs ps join descpub_swg wg on ps.swg_id = wg.id
           join descpub_publication dd on dd.project_id = ps.project_id where dd.paperid = ?
           <sql:param value="${param.paperid}"/>
        </sql:query>
        <c:set var="convenerGrp" value="${leads.rows[0].convener_group_name}"/>
      
        <%-- check for versions --%>
        <sql:query var="vers">
            select paperid, version, to_char(tstamp,'YYYY-Mon-DD HH:MI:SS') tstamp, to_char(tstamp,'YYYY-Mon-DD HH:MI:SS') pst, remarks from descpub_publication_versions where paperid=? order by version desc
            <sql:param value="${param.paperid}"/>
        </sql:query>
       
        <%-- get paper leads --%>
        <sql:query var="leadauth">
            select u.first_name, u.last_name, u.email, u.memidnum, u.user_name from profile_user u join profile_ug ug on u.memidnum = ug.memidnum and u.experiment = ug.experiment
            where u.active = 'Y' and ug.group_id = ? and ug.experiment = ? order by u.last_name
            <sql:param value="${paperLeadGrpName}"/>
            <sql:param value="${appVariables.experiment}"/>
        </sql:query>
            
        <c:forEach var="la" items="${leadauth.rows}">
            <c:choose>
                <c:when test="${empty primaryauths}">
                    <c:set var="primaryauths" value="${la.first_name}:${la.last_name}:${la.memidnum}"/>
                    <c:set var="authAddrs" value="${la.email}"/>
                </c:when>
                <c:when test="${!empty primaryauths}">
                    <c:set var="primaryauths" value="${primaryauths},${la.first_name}:${la.last_name}:${la.memidnum}"/>
                    <c:set var="authAddrs" value="${authAddrs},${la.email}"/>
                </c:when>
            </c:choose>
        </c:forEach>
            
        <h2>Document: <strong>DESC-${param.paperid}</strong></h2>  
         
        <c:choose>
        <c:when test="${fn:contains(reviewList,'@')}">
            <p id="pagelabel"><a href="mailto:${reviewAll}">Reviewers</a>: ${reviewList} </p>
        </c:when>
        <c:otherwise>
            <p id="pagelabel">${reviewList}</p>
        </c:otherwise>
        </c:choose>  
            
        <table class="datatable">
            <utils:trEvenOdd reset="true"><th style="text-align: left;">Document type</th><td style="text-align: left">${pubs.rows[0]['pubtype']}</td></utils:trEvenOdd>
            <c:choose>
            <c:when test="${projid > 0}">
                <utils:trEvenOdd reset="false"><th style="text-align: left">Project id</th><td style="text-align: left"><a href="projectView.jsp?projid=${pubs.rows[0]['project_id']}">${pubs.rows[0]['project_id']}</a></td></utils:trEvenOdd>
            </c:when>
            <c:when test="${projid == 0}">
                <utils:trEvenOdd reset="false"><th style="text-align: left">Project id</th><td style="text-align: left">${pubs.rows[0]['project_id']}</td></utils:trEvenOdd>
            </c:when>
            </c:choose>
            <c:if test="${projid == 0}">
                <utils:trEvenOdd reset="false"><th style="text-align: left">Working Group</th><td style="text-align: left">${projLessWG}</td></utils:trEvenOdd>
            </c:if>
            <c:forEach var="x" items="${pubs.columnNames}">
                <c:forEach var="f" items="${fi.rows}">
                    <c:if test="${fn:toLowerCase(x) == f.data}">
                        <c:choose>
                            <c:when test="${f.datatype == 'url' && (fn:startsWith(pubs.rows[0][f.data],'http') || fn:startsWith(pubs.rows[0][f.data],'https'))}">
                                <utils:trEvenOdd reset="false"><th style="text-align: left">${f.label}</th><td style="text-align: left"><a href="${pubs.rows[0][f.data]}">link</a></td></utils:trEvenOdd>
                            </c:when>
                            <c:when test="${f.data == 'can_request_authorship' && pubs.rows[0][f.data] == 'Y'}">
                                <utils:trEvenOdd reset="false"><th style="text-align: left">Request authorship</th><td style="text-align: left"><a href="requestAuthorship.jsp?paperid=${param.paperid}">DESC-${param.paperid} request</a></td></utils:trEvenOdd>
                            </c:when> 
                            <c:otherwise>
                                <utils:trEvenOdd reset="false"><th style="text-align: left">${f.label}</th><td style="text-align: left">${pubs.rows[0][f.data]}</td></utils:trEvenOdd>
                            </c:otherwise>
                        </c:choose>
                    </c:if>
                </c:forEach>
            </c:forEach>
           
            <utils:trEvenOdd reset="false"><th style="text-align: left">Reviewers</th>
                <td style="text-align:left">${reviewList}<td/>
            </utils:trEvenOdd>
                
            <utils:trEvenOdd reset="false"><th style="text-align: left">Lead authors</th>
                <td style="text-align: left">
                    <c:set var="parts" value="${fn:split(primaryauths,',')}"/>
                    <c:forEach var="p" items="${parts}" varStatus="status">
                        <c:set var="lead_author" value="${fn:split(p,':')}"/>
                        <a href="http://srs.slac.stanford.edu/GroupManager/exp/LSST-DESC/protected/user.jsp?memidnum=${lead_author[2]}">${lead_author[0]} ${lead_author[1]}&nbsp;</a>
                    </c:forEach>
                </td>
            </utils:trEvenOdd>
            <c:if test="${!empty authAddrs}">
                <utils:trEvenOdd reset="false"><th style="text-align: left">Email to</th>
                    <td style="text-align:left"><a href="mailto:${authAddrs}">Paper Leads</a></td>
                </utils:trEvenOdd> 
            </c:if> 
           
            <c:if test="${gm:isUserInGroup(pageContext,paperGrpName) || gm:isUserInGroup(pageContext,paperLeadGrpName) || gm:isUserInGroup(pageContext,projectGrpName) || gm:isUserInGroup(pageContext,paperReviewGrp) || gm:isUserInGroup(pageContext,'GroupManagerAdmin') || gm:isUserInGroup(pageContext,'lsst-desc-publications-admin')}">
                <utils:trEvenOdd reset="false"><th style="text-align: left">Edit</th>
                    <td style="text-align: left">
                    <a href="editLink.jsp?paperid=${param.paperid}">DESC-${param.paperid}</a>
                    </td>
                </utils:trEvenOdd>
            </c:if>
               
        </table>
            
        <c:if test="${vers.rowCount > 0}">
            <display:table class="datatable" id="row" name="${vers.rows}">
                <display:column title="Versions of DESC-${row.paperid}" sortable="true" headerClass="sortable">
                    <a href="download?paperid=${row.paperid}&version=${row.version}">Download version ${row.version}</a>
                </display:column>
                <display:column title="Remarks" property="remarks"/>
                <display:column title="Uploaded (UTC)">
                    ${row.tstamp}
                </display:column>
            </display:table>
            <p/> 
        </c:if>
      
        <c:if test="${gm:isUserInGroup(pageContext,'lsst-desc-publications-admin') || gm:isUserInGroup(pageContext,paperLeadGrpName) || gm:isUserInGroup(pageContext,paperGrpName) || gm:isUserInGroup(pageContext,'GroupManagerAdmin') || gm:isUserInGroup(pageContext,'lsst-desc-publications-admin')}">
        <form action="upload_doc.jsp" method="post" enctype="multipart/form-data"> <%-- upload_doc.jsp is the ur-pattern for the servlet --%>
            <div>
              <fieldset class="fieldset-auto-width">
                  <legend><strong>Upload</strong></legend><p/>
                  Upload new version of DESC-${param.paperid}<p/>
                  <input type="file" name="fileToUpload" id="fileToUpload"><p/>
                  Remarks: <input type="text" name="remarks"><p/>
                  <input type="submit" value="Upload Document" name="submit">
                  <input type="hidden" name="forwardTo" value="/uploadPub.jsp?paperid=${param.paperid}" />
                  <input type="hidden" name="paperid" value="${param.paperid}"/>
              </fieldset>
            </div>
        </form>
        </c:if>
    </body>
</html>
