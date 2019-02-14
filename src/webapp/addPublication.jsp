<%-- 
    Document   : addPublication
    Created on : Aug 3, 2017, 1:38:15 PM
    Author     : chee
--%>

<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <script src="../js/jquery-1.11.1.min.js"></script>
        <script src="../js/jquery.validate.min.js"></script>
        <link rel="stylesheet" type="text/css" href="css/pubstyles.css">
        <title>Add Document</title>
    </head>
    <body>

    <%-- Notes:
    state = the current state of the paper as it goes from create to review to published.
    status = paper is either internal to the collaboration or public
    DOI = digital object identifier, stem is always https://doi.org/<user input>
    ADS = astrophysics data system, stem is always adsabs.harvard.edu/abs/<user input>
    arXiv = arxiv, stem is always https://arxiv.org/abs/<user input>
    projid = 0 means the document is not associated with any project
    --%>
    <c:set var="debugMode" value="false"/>
    
    <c:if test="${debugMode =='true'}">
        <c:forEach var="pa" items="${param}">
            <c:out value="${pa.key} = ${pa.value}"/><br/>
        </c:forEach>
    </c:if>
    
    <sql:query var="ptypes">
        select pubtype from descpub_publication_types 
        <c:if test="${param.projid == 0}">
            where projectless = 'Y'
        </c:if>
        order by pubtype
    </sql:query>
        
    <c:choose>
        <c:when test="${param.task == 'create_publication_form'}">
            <form action="addPublication.jsp" method="post">  
                 <p id="pagelabel">Select document type:</p>
                    <select name="pubtype" required>
                       <option value=""></option>
                       <c:forEach var="ptype" items="${ptypes.rows}">
                           <option value="${ptype.pubtype}">${ptype.pubtype}</option>
                       </c:forEach>
                    </select>
                 <input type="hidden" name="ptype_selected" value="true"/>
                 <input type="hidden" name="projid" value="${param.projid}"/>
                 <input type="hidden" name="swgid" value="${param.swgid}"/>  
                 <input type="submit" value="Continue" name="submit" /> 
            </form>
        </c:when>
        <c:when test="${param.ptype_selected == 'true' && param.formsubmitted != 'true'}">
                <sql:query var="fields">
                   select * from descpub_metadata me join descpub_pubtype_fields pb on me.metaid = pb.metaid where pb.pubtype = ? order by formposition
                   <sql:param value="${param.pubtype}"/>
                </sql:query>
                   
                <c:if test="${param.projid != '0'}">
                    <sql:query var="projInfo">
                       select p.id, p.title, s.name from descpub_project p join descpub_project_swgs j on p.id=j.project_id
                       join descpub_swg s on s.id=j.swg_id  where p.id = ? and s.id = ?
                       <sql:param value="${param.projid}"/>
                       <sql:param value="${param.swgid}"/>
                    </sql:query>
                </c:if>
                
                <sql:query var="poolOfCandidates">
                    select m.lastname, m.firstname, m.memidnum, u.username from um_member m join um_project_members p on m.memidnum=p.memidnum
                    join um_member_username u on u.memidnum=m.memidnum where p.activestatus = 'Y' and p.project = ? and m.lastname != 'lsstdesc-user' 
                    order by lower(m.lastname)
                    <sql:param value="${appVariables.experiment}"/>
                </sql:query>
                    
              <%--  <c:set var="arrayDetails" value="${param.pubtype},${projInfo.rows[0].title},${projInfo.rows[0].name}"/>  --%>  

                <div class="intro">
                    <p id="pagelabel">Document Details</p>
                    <strong>Document type: ${param.pubtype}<br/>
                    <c:if test="${param.projid != '0'}">
                       Project id: [ <a href="show_project.jsp?projid=${projInfo.rows[0].id}">${projInfo.rows[0].id}</a> ] ${projInfo.rows[0].title}. <br/> 
                    </c:if>
                    Working group(s): ${projInfo.rows[0].name}</strong>
                    <p></p>
                </div> 
                    
                <form action="addPublication.jsp" method="post" id="addPublication" name="addPublication">
                    <div id="formRequest">
                        <fieldset class="fieldset-auto-width">
                    <legend>New document form</legend>
                    <c:forEach var="x" items="${fields.rows}">
                        <c:set var="required" value="${!empty x.required ? 'required' : ''}"/>
                        <c:if test="${!empty x.fieldexplanation}">
                            <p id="pagelabel">  <c:out value="${x.fieldexplanation}"/></p>
                        </c:if>
                            
                        <c:if test="${x.datatype == 'string'}">
                            <c:if test="${!empty x.numcols}">
                                <c:set var="size" value="size=${x.numcols}"/>
                            </c:if>
                            ${x.label} <input type ="text" name="${x.data}" ${size} ${required}/> 
                           <p></p>
                        </c:if>
                           
                        <c:if test="${x.datatype == 'dropbox'}">
                           <sql:query var="results">
                                select metavalue, defaultvalue from descpub_metadata_enum where metaid = ?
                                <sql:param value="${x.metaid}"/>
                           </sql:query>
                           ${x.label}:  
                           <select name="${x.data}" ${required}>
                                <c:forEach var="erow" items="${results.rows}">
                                   <c:if test="${erow.defaultvalue == 'Y'}">
                                       <option value="${erow.metavalue}" selected>${erow.metavalue} </option>
                                   </c:if>
                                   <c:if test="${erow.defaultvalue != 'Y'}">
                                       <option value="${erow.metavalue}">${erow.metavalue} </option>
                                   </c:if>
                                </c:forEach>
                            </select> 
                                <p></p>
                        </c:if>
                               
                        <c:if test="${x.datatype == 'list'}">
                            <p></p>
                            ${x.label}:  
                            <sql:query var="results">
                                ${x.sqlstr}
                            </sql:query>
                             
                            <c:if test="${fn:contains(x.data,'institution')}">
                                 <select name="${x.data}" ${required}>
                                     <c:forEach var="in" items="${results.rows}">
                                      <option value="${in['institution']}">${in['institution']}</option>
                                     </c:forEach>
                                      <option value="${x.data}">${irow['current_institution']}</option>
                                 </select>
                            </c:if>
                            
                            <%-- not using state
                            <c:if test="${x.data == 'state'}">
                                <c:set var="selected" value=""/>
                                 <select name="${x.data}" ${required}>
                                     <option value="created">created</option>
                                 </select>  
                            </c:if> --%>
                            
                            <c:if test="${x.data == 'pubstatus'}">
                                <input type="hidden" name="${x.data}" value="created">created</option>
                            </c:if>
                            
                            <p></p>
                        </c:if>
                           
                        <c:if test="${x.datatype == 'textarea'}">
                            <sql:query var="rowcol">
                                select numrows, numcols from descpub_metadata where metaid = ?
                                <sql:param value="${x.metaid}"/>
                            </sql:query>
                            <c:set var="numrows" value="${empty rowcol.rows[0].numrows ? '20' : rowcol.rows[0].numrows}"/>
                            <c:set var="numcols" value="${empty rowcol.rows[0].numcols ? '20' : rowcol.rows[0].numcols}"/>
                            <p></p>
                            ${x.label}:<br/><textarea name="${x.data}" rows="${numrows}" cols="${numcols}" ${required}></textarea><br/>
                            <p></p>
                        </c:if>
                            
                        <c:if test="${x.datatype == 'checkbox'}">
                             <p></p>
                            <sql:query var="enums">
                                select * from descpub_metadata_enum where metaid = ?
                                <sql:param value="${x.metaid}"/>
                            </sql:query>
                            <c:forEach var="chkbx" items="${enums.rows}">
                              ${chkbx.metavalue}   <input type="checkbox" name="${x.data}" value="${chkbx.metavalue}" ${required}/><br/>
                            </c:forEach>
                               <p></p>
                        </c:if> 
                               
                        <c:if test="${x.datatype == 'url'}">
                            <p></p>
                           ${x.label}: <input type="text" name="${x.data}" value="${results.rows[0][x.data]}" size="${x.numcols}"/>
                           <p></p>
                        </c:if>  
                               
                    </c:forEach>
                    </fieldset>
                    </div>
                               
                    <p id="pagelabel">
                    Select Lead Author(s):</p>  
                    <select name="authcontacts" multiple size="20" required>
                    <c:forEach var="auth" items="${poolOfCandidates.rows}">
                        <option value="${auth.memidnum}:${auth.firstname} ${auth.lastname}:${auth.username}">${auth.lastname},  ${auth.firstname} </option>
                    </c:forEach>
                    </select>
                    <p></p>
                    <p id="pagelabel">
                    Select Reviewer(s):</p>  
                    <select name="reviewers" multiple size="20">
                    <c:forEach var="revs" items="${poolOfCandidates.rows}">
                        <option value="${revs.memidnum}:${revs.firstname} ${revs.lastname}:${revs.username}">${revs.lastname},  ${revs.firstname} </option>
                    </c:forEach>
                    </select>
                   <br/>
                     <input type="hidden" name="projid" id="projid" value="${param.projid}"/> 
                     <input type="hidden" name="swgid" id="swgid" value="${param.swgid}"/>
                     <input type="hidden" name="pubtype" value="${param.pubtype}"/>
                     <input type="hidden" name="formsubmitted" value="true"/>
                     <p></p>
                     <input type="submit" value="Create Document Entry" name="submit" />  
                </form>
        </c:when>
        <c:when test="${param.formsubmitted == 'true' && debugMode == 'true'}">
            <c:out value="User Form Input"/><br/>
            <c:forEach var="p" items="${param}">
                <c:out value="${p.key} = ${p.value}"/><br/>
            </c:forEach>
            
             <%-- get fields for this pubtype --%>
            <sql:query var="res">
                select label, data, datatype from descpub_pubtype_fields pb join descpub_metadata me on pb.metaid = me.metaid where pb.pubtype = ? order by formposition
                <sql:param value="${param.pubtype}"/>
            </sql:query>   
            
            <sql:query var="stamp"> <%-- generate fake id for testing --%>
               select  extract(second  from (sysdate - timestamp '1970-01-01 00:00:00')) * 3600 unix_time from dual
            </sql:query>
            <c:set var="current" value="${stamp.rows[0]['unix_time']}"/>

             <c:forEach var="cn" items="${res.rows}">
                 <c:choose>
                     <c:when test="${empty colnames}">
                         <c:set var="colnames" value="${cn.data}"/>
                         <c:set var="qmarks" value="?"/>
                     </c:when>
                     <c:when test="${! empty colnames}">
                         <c:set var="colnames" value="${colnames}, ${cn.data}"/>
                         <c:set var="qmarks" value="${qmarks},?"/>
                     </c:when>
                 </c:choose>
             </c:forEach>
            
            <c:set var="colnames" value="${colnames},paperid,project_id,createdate,createdby,pubtype"/>
            <c:set var="qmarks" value="${qmarks},?,?,sysdate,?,?"/>
            <h3>insert into descpub_publication_test (${colnames}) values (${qmarks})<br/>
                <c:forEach var="v" items="${res.rows}">
                    <c:out value="sql:param value=${empty param[v.data] ? NULL : param[v.data]}"/><br/>
                </c:forEach>
                <c:out value="sql:param value=${current}"/><br/>
                <c:out value="sql:param value=${param.projid}"/><br/>
                <c:out value="sql:param value=${userName}"/><br/>
                <c:out value="sql:param value=${param.pubtype}"/><br/>   
            </h3>
           
            <%-- descpub_publication_test is a debugging table --%>
            <sql:update>
              insert into descpub_publication_test (${colnames})  values (${qmarks})
                  <c:forEach var="cn" items="${res.rows}">
                      <sql:param value = "${empty param[cn.data] ? 'NULL' : param[cn.data]}"/>
                  </c:forEach> 
                  <sql:param value="${current}"/>
                  <sql:param value="${param.projid}"/>
                  <sql:param value="${userName}"/>
                  <sql:param value="${param.pubtype}"/>
            </sql:update> 
              
        </c:when>
        <c:when test="${param.formsubmitted && debugMode == 'false' }">
            <%-- get fields for this pubtype --%>
            <sql:query var="res">
                select label, data, datatype from descpub_pubtype_fields pb join descpub_metadata me on pb.metaid = me.metaid where pb.pubtype = ? order by formposition
                <sql:param value="${param.pubtype}"/>
            </sql:query>  
                
            <c:forEach var="cn" items="${res.rows}">
                 <c:choose>
                     <c:when test="${empty colnames}">
                         <c:set var="colnames" value="${cn.data}"/>
                         <c:set var="qmarks" value="?"/>
                     </c:when>
                     <c:when test="${! empty colnames}">
                         <c:set var="colnames" value="${colnames}, ${cn.data}"/>
                         <c:set var="qmarks" value="${qmarks},?"/>
                     </c:when>
                 </c:choose>
             </c:forEach>
             
            <%-- tack on a few document details that are not in the metadata table --%>
            <c:set var="colnames" value="${colnames},paperid,project_id,createdate,createdby,pubtype"/>
             <c:set var="qmarks" value="${qmarks},DESCPUB_PUB_SEQ.nextval,?,sysdate,?,?"/>
            
            <c:set var="trapError" value=""/>
            
            <c:catch var="trapError"> 
                <sql:transaction>   
                   <sql:update>
                     insert into descpub_publication (${colnames}) values (${qmarks}) 
                     <c:forEach var="cn" items="${res.rows}">
                       <sql:param value = "${empty param[cn.data] ? NULL : param[cn.data]}"/>
                     </c:forEach> 
                     <sql:param value="${param.projid}"/>
                     <sql:param value="${userName}"/>
                     <sql:param value="${param.pubtype}"/>
                   </sql:update>
                     
                   <%-- get the paperid, add it to the insert fields and create the associated groups for the paper --%>
                    <sql:query var="curr">
                        select DESCPUB_PUB_SEQ.currval as currval from dual
                    </sql:query>
                    <c:set var="current" value="${curr.rows[0].currval}"/>
                     
                    <%-- if project-less document update working group for document --%>
                    <c:if test="${param.projid == 0}">
                        <sql:update>
                            insert into descpub_publication_swgs (paperid, swgid, entrydate) values (?,?,sysdate)
                            <sql:param value="${current}"/>
                            <sql:param value="${param.swgid}"/>
                        </sql:update>
                    </c:if>
                    
                    <%-- build the groups for this document --%>
                    <c:set var="group_name" value="paper_${current}"/> 
                    <c:set var="leadauthgrp" value="paper_leads_${current}"/>
                    <c:set var="reviewergrp" value="paper_reviewers_${current}"/>
                    <c:set var="grpmanager" value="lsst-desc-publications-admin"/>
                    
                    <%-- insert group name into profile_group, initially empty, members will be added via grpmgr, paper lead group is the managing group --%> 
                    <sql:update>
                        insert into profile_group (group_name,group_manager,experiment) values (?, ?, ?)
                        <sql:param value="${group_name}"/>
                        <sql:param value="${leadauthgrp}"/>
                        <sql:param value="${appVariables.experiment}"/>
                    </sql:update> 
                        
                    <%-- insert group name for lead authors, lsst-desc-publications-admin is the managing group --%> 
                    <sql:update>
                        insert into profile_group (group_name,group_manager,experiment) values (?, ?, ?)
                        <sql:param value="${leadauthgrp}"/>
                        <sql:param value="${grpmanager}"/>
                        <sql:param value="${appVariables.experiment}"/>
                    </sql:update> 
                        
                     <%-- add selected authors to group for lead authors --%> 
                    <c:forEach var="con" items="${paramValues['authcontacts']}">
                        <c:set var="array" value="${fn:split(con,':')}"/>
                        <sql:update>
                            insert into profile_ug (user_id, group_id, experiment, memidnum) values(?,?,?,?)
                            <sql:param value="${array[2]}"/>
                            <sql:param value="${leadauthgrp}"/>
                            <sql:param value="${appVariables.experiment}"/>
                            <sql:param value="${array[0]}"/>
                        </sql:update> 
                    </c:forEach>    

                    <%-- insert paper reviewer group name into profile_group, lsst-desc-publications-admin is the managing group --%> 
                    <sql:update>
                        insert into profile_group (group_name,group_manager,experiment) values (?, ?, ?)
                        <sql:param value="${reviewergrp}"/>
                        <sql:param value="${grpmanager}"/>
                        <sql:param value="${appVariables.experiment}"/>
                    </sql:update> 

                    <%-- add reviewers to the reviewers group  --%>
                    <c:forEach var="rev" items="${paramValues['reviewers']}">
                        <c:set var="revarray" value="${fn:split(rev,':')}"/>
                        <sql:update>
                            insert into profile_ug (user_id, group_id, experiment, memidnum) values(?,?,?,?)
                            <sql:param value="${revarray[2]}"/>
                            <sql:param value="${reviewergrp}"/>
                            <sql:param value="${appVariables.experiment}"/>
                            <sql:param value="${revarray[0]}"/>
                        </sql:update> 
                    </c:forEach>
                </sql:transaction>
            </c:catch>
       
            <c:if test="${trapError != null}">
                <h1>Error. Failed to create document: ${param.title}<br/>
                    Parent key is ${param.projid}<br/>
                    CurrSequence: ${current}<br/>
                    Colnames: ${colnames}<br/>
                    Qmarks: ${qmarks}<br/>
                    <p>TrapError</p>
                    ${trapError}<br/>
                    <p></p>
                    <c:forEach var="par" items="${param}">
                      <c:out value="PARAM=${par.key}=${par.value}"/><br/>
                    </c:forEach>
                </h1>
            </c:if>
            <c:if test="${trapError == null}">
              <c:redirect url="show_pub.jsp?paperid=${current}"/>   
            </c:if>
       </c:when>
                            
    </c:choose>
    </body>
</html>
