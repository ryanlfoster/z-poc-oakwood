<%@page session="false"%><%--
  Copyright 1997-2010 Day Management AG
  Barfuesserplatz 6, 4001 Basel, Switzerland
  All Rights Reserved.

  This software is the confidential and proprietary information of
  Day Management AG, ("Confidential Information"). You shall not
  disclose such Confidential Information and shall use it only in
  accordance with the terms of the license agreement you entered into
  with Day.

  ==============================================================================

  Default init script.

  Draws the WCM initialization code. This is usually called by the head.jsp
  of the page. If the WCM is disabled, no output is written.

  ==============================================================================

--%><%@include file="/libs/foundation/global.jsp" %><%
%><%@page import="com.day.cq.wcm.api.AuthoringUIMode,
      			  com.day.cq.wcm.core.utils.ScaffoldingUtils,
                  com.day.cq.wcm.api.WCMMode" %><%
%><%

    if (WCMMode.fromRequest(request) != WCMMode.DISABLED) {
        String dlgPath = null;
        if (editContext != null && editContext.getComponent() != null) {
            dlgPath = editContext.getComponent().getDialogPath();
        }
        if (AuthoringUIMode.fromRequest(slingRequest) != AuthoringUIMode.CLASSIC) {
            %><cq:includeClientLib categories="cq.authoring.page" /><%
        } else {
			String path = currentPage.getPath();
            Resource actualResource = (Resource)request.getAttribute(ScaffoldingUtils.CONTEXT_RESOURCE_ATTR_NAME);
            if(actualResource!=null && currentPage.getPath().startsWith("/etc/scaffolding/")){
				 path  = actualResource.getPath();
            }

            %><cq:includeClientLib categories="cq.wcm.edit" />
            <script type="text/javascript">
                (function() {

                    var cfg = <%
                            try {
                                sling.getService(com.day.cq.wcm.undo.UndoConfigService.class)
                                        .writeClientConfig(out);
                            } catch (Exception e) {
                                // ignore
                            }
                        %>;
                    <%-- explicitly set page path, as under some circumstances, CQ.WCM.getPagePath() --%>
                    <%-- may yield unwanted results at this point                                    --%>
                    cfg.pagePath = "<%= path%>";

                    if (CQClientLibraryManager.channelCB() != "touch") {
                        var isEditMode = <%= WCMMode.fromRequest(request) == WCMMode.EDIT ? "true" : "false" %>;
                        if (!isEditMode) {
                            cfg.enabled = false;
                        }
                        CQ.undo.UndoManager.initialize(cfg);
                        CQ.Ext.onReady(function() {
                            CQ.undo.UndoManager.detectCachedPage(<%= System.currentTimeMillis() %>);
                        });
                    }
                })();

                CQ.WCM.launchSidekick("<%=path%>", {
                    propsDialog: "<%= dlgPath == null ? "" : dlgPath %>",
                    locked: <%= currentPage.isLocked() %>
                });
            </script>
            <%
        }
    }
%>