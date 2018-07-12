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
    DOI = digital object identifier
    ADS = astrophysics data system
    --%>
    <c:set var="debugMode" value="true"/>
    
    <c:if test="${debugMode =='true'}">
        <c:forEach var="pa" items="${param}">
            <c:out value="${pa.key} = ${pa.value}"/><br/>
        </c:forEach>
    </c:if>
    
    <sql:query var="ptypes">
        select pubtype from descpub_publication_types order by pubtype
    </sql:query>
        
    <c:choose>
        <c:when test="${param.task == 'create_publication_form'}">
            <form action="addPublication.jsp" method="post">  
                 <p id="pagelabel">Select publication type:</p>
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
            <%--
                <sql:query var="fields">
                   select me.metaid, me.label, me.data, me.datatype, me.numrows, me.numcols, pb.fieldexplanation, pb.required, pb.sqlstr from 
                   descpub_metadata me join descpub_pubtype_fields pb on me.metaid = pb.metaid where pb.pubtype = ? 
                   order by formposition
                   <sql:param value="${param.pubtype}"/>
                </sql:query> --%>
                   
                <sql:query var="fields">
                   select * from descpub_metadata me join descpub_pubtype_fields pb on me.metaid = pb.metaid where pb.pubtype = ? order by formposition
                   <sql:param value="${param.pubtype}"/>
                </sql:query>
                   
                <sql:query var="projInfo">
                   select p.id, p.title, s.name from descpub_project p join descpub_project_swgs j on p.id=j.project_id
                   join descpub_swg s on s.id=j.swg_id  where p.id = ? and s.id = ?
                   <sql:param value="${param.projid}"/>
                   <sql:param value="${param.swgid}"/>
                </sql:query>

                <sql:query var="poolOfCandidates">
                    select m.firstname, m.lastname, m.memidnum, u.username from um_member m join um_project_members p on m.memidnum=p.memidnum
                    join um_member_username u on u.memidnum=m.memidnum where p.activestatus = 'Y' and p.project = ? and m.lastname != 'lsstdesc-user' 
                    order by lower(m.lastname)
                    <sql:param value="${appVariables.experiment}"/>
                </sql:query>
                    
                <c:set var="arrayDetails" value="${param.pubtype},${projInfo.rows[0].title},${projInfo.rows[0].name}"/>    

                <div class="intro">
                    <p id="pagelabel">Document Details</p>
                    <strong>Pubtype: ${param.pubtype}<br/>
                    Project id: [ <a href="show_project.jsp?projid=${projInfo.rows[0].id}">${projInfo.rows[0].id}</a> ] ${projInfo.rows[0].title}. <br/> 
                    Working group(s): ${projInfo.rows[0].name}</strong>
                    <p></p>
                </div> 
              
                
                <form action="addPublication.jsp" method="post" id="addPublication" name="addPublication">
                    <div id="formRequest">
                    <fieldset>
                    <legend>New document form</legend>
                    <c:forEach var="x" items="${fields.rows}">
                        <c:set var="required" value="${!empty x.required ? 'required' : ''}"/>
                        <c:if test="${!empty x.fieldexplanation}">
                            <p id="pagelabel">  <c:out value="${x.fieldexplanation}"/></p>
                        </c:if>
                            
                        <c:if test="${x.datatype == 'string'}">
                           ${x.label}: <input type ="text" name="${x.data}"  ${required}/> 
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
                            
                            <c:if test="${x.data == 'state'}">
                                <c:set var="selected" value=""/>
                                 <select name="${x.data}" ${required}>
                                     <option value="created">created</option>
                                 </select>  
                            </c:if>
                            
                            <p></p>
                        </c:if>
                           
                        <c:if test="${x.datatype == 'textarea'}">
                            <c:set var="textrow" value=""/> 
                            <c:set var="textcol" value=""/>
                            <sql:query var="rowcol">
                                select metavalue from descpub_metadata_enum where metaid = ?
                                <sql:param value="${x.metaid}"/>
                            </sql:query>
                            <c:set var="arr" value="${fn:split(rowcol,':')}"/>

                            <c:choose>
                                <c:when test="${!empty array}">
                                    <p></p>
                                    ${x.label}:<br/> <textarea rows=${arr[0]} cols=${arr[1]} name=${x.data} ${required}></textarea><br/>
                                    <p></p>
                                </c:when>
                                <c:when test="${empty rowcol.rowCount || rowcol.rowCount < 1}">
                                    <p></p>
                                    ${x.label}:<br/>  <textarea name="${x.data}" ${required}></textarea><br/>
                                    <p></p>
                                </c:when>
                            </c:choose>
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
                    
                   <br/> 
                     <input type="hidden" name="projid" id="projid" value="${param.projid}"/> 
                     <input type="hidden" name="swgid" id="swgid" value="${param.swgid}"/>
                     <input type="hidden" name="pubtype" value="${param.pubtype}"/>
                     <input type="hidden" name="formsubmitted" value="true"/>
                     <p></p>
                     <input type="submit" value="Create Document Entry" name="submit" />  
                </form>
        </c:when>
        <c:when test="${param.formsubmitted == 'true' && debugMode}">
            <sql:query var="res">
                select me.metaid, me.data, me.label, pb.multiplevalues from descpub_pubtype_fields pb join descpub_metadata me on pb.metaid = me.metaid
                where pb.pubtype = ?
                <sql:param value="${param.pubtype}"/>
            </sql:query>
              
            <c:set var="current" value="99999"/>
             <br>
             <c:forEach var="par" items="${param}">
                 <c:forEach var="fi" items="${res.rows}" varStatus="loop">
                     
                     <c:choose>
                         <c:when test="${fi.data == par.key && empty fieldstr && !empty par.value}">
                             <c:set var="fieldstr" value="${fi.data}"/>
                             <c:set var="valuestr" value="${par.value}"/>
                             <c:set var="qmarks" value="?"/>
                         </c:when>
                         <c:when test="${fi.data == par.key && !empty fieldstr && !empty par.value}">
                             <c:set var="fieldstr" value="${fieldstr},${fi.data}"/>
                             <c:set var="valuestr" value="${valuestr},${par.value}"/>
                             <c:set var="qmarks" value="${qmarks},?"/>
                         </c:when>
                     </c:choose>
                     
                 </c:forEach>
             </c:forEach>
             
             <c:set var="fieldstr" value="${fieldstr},paperid,project_id,createdate,pubtype"/>
             <c:set var="valuestr" value="${valuestr},${param.projid},${param.pubtype}"/>
             <c:set var="qmarks" value="${qmarks},DESCPUB_PUB_SEQ.nextval,?,sysdate,?"/>
             
             <sql:update>
                 insert into descpub_publication (${fieldstr}) values (${qmarks}) 
                 <c:forEach var="x" items="${valuestr}">
                     <sql:param value="${x}"/>
                 </c:forEach>
             </sql:update>
                 
             <p></p>
        </c:when>
        <c:when test="${param.formsubmitted && !debugMode}">
            <%-- get fields for this pubtype --%>    
            <sql:query var="res">
                select pb.metaid, me.data, me.label, pb.multiplevalues from descpub_pubtype_fields pb join descpub_metadata me on pb.metaid = me.metaid
                where pb.pubtype = ? order by pb.formposition
                <sql:param value="${param.pubtype}"/>
            </sql:query>
          
            <c:set var="fieldstr" value=""/>
            <c:set var="valuestr" value=""/>
            <c:set var="qmarks" value=""/>
        
            <c:forEach var="par" items="${param}">
                 <c:forEach var="fi" items="${res.rows}" varStatus="loop">

                     <c:choose>
                         <c:when test="${fi.data == par.key && empty fieldstr && !empty par.value}">
                             <c:set var="fieldstr" value="${fi.data}"/>
                             <c:set var="valuestr" value="${par.value}"/>
                             <c:set var="qmarks" value="?"/>
                         </c:when>
                         <c:when test="${fi.data == par.key && !empty fieldstr && !empty par.value}">
                             <c:set var="fieldstr" value="${fieldstr},${fi.data}"/>
                             <c:set var="valuestr" value="${valuestr},${par.value}"/>
                             <c:set var="qmarks" value="${qmarks},?"/>
                         </c:when>
                     </c:choose>

                 </c:forEach>
            </c:forEach>

            <%-- tack on a few document details that are not in the metadata table --%>
            <c:set var="fieldstr" value="${fieldstr},paperid,project_id,createdate,createdby,pubtype"/>
            <c:set var="valuestr" value="${valuestr},${param.projid},${userName},${param.pubtype}"/>
            <c:set var="qmarks" value="${qmarks},DESCPUB_PUB_SEQ.nextval,?,sysdate,?,?"/>
            
            <c:catch var="trapError"> 
                <sql:transaction>   
                   <sql:update>
                     insert into descpub_publication (${fieldstr}) values (${qmarks}) 
                     <c:forEach var="x" items="${valuestr}">
                         <sql:param value="${x}"/>
                     </c:forEach>
                   </sql:update>

                    <%-- get the paperid, add it to the insert fields and create the associated groups for the paper --%>
                    <sql:query var="curr">
                        select DESCPUB_PUB_SEQ.currval as currval from dual
                    </sql:query>
                        
                    <%-- get the current pub sequence number --%>
                    <c:set var="current" value="${curr.rows[0].currval}"/>
                    
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

                    ${trapError}<br/>
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
