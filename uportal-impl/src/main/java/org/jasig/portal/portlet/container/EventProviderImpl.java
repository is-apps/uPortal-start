/**
 * Copyright (c) 2000-2010, Jasig, Inc.
 * See license distributed with this file and available online at
 * https://www.ja-sig.org/svn/jasig-parent/tags/rel-10/license-header.txt
 */

package org.jasig.portal.portlet.container;

import java.io.Serializable;
import java.io.StringWriter;
import java.io.Writer;
import java.util.List;

import javax.portlet.Event;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBElement;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Marshaller;
import javax.xml.namespace.QName;
import javax.xml.stream.FactoryConfigurationError;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.pluto.container.EventProvider;
import org.apache.pluto.container.om.portlet.EventDefinition;
import org.apache.pluto.container.om.portlet.EventDefinitionReference;
import org.apache.pluto.container.om.portlet.PortletApplicationDefinition;
import org.apache.pluto.container.om.portlet.PortletDefinition;
import org.jasig.portal.portlet.om.IPortletWindow;

/**
 * @author Eric Dalquist
 * @version $Revision$
 */
public class EventProviderImpl implements EventProvider {
    protected final Log logger = LogFactory.getLog(this.getClass());
    
    private IPortletWindow portletWindow;

    public EventProviderImpl(IPortletWindow portletWindow) {
        this.portletWindow = portletWindow;
    }

    @SuppressWarnings("unchecked")
    public Event createEvent(QName qname, Serializable value) throws IllegalArgumentException {
        if (this.isDeclaredAsPublishingEvent(qname)) {
            if (value != null && !this.isValueInstanceOfDefinedClass(qname, value)) {
                throw new IllegalArgumentException("Payload class (" + value.getClass().getCanonicalName()
                        + ") does not have the right class, check your defined event types in portlet.xml.");
            }
            

            if (value == null) {
                return new EventImpl(qname, value);
            }
            
            try {
                final Thread currentThread = Thread.currentThread();
                final ClassLoader cl = currentThread.getContextClassLoader();
                final Writer out = new StringWriter();
                final Class clazz = value.getClass();
                try {
                    currentThread.setContextClassLoader(this.getClass().getClassLoader());
                    final JAXBContext jc = JAXBContext.newInstance(clazz);
                    final Marshaller marshaller = jc.createMarshaller();
                    final JAXBElement<Serializable> element = new JAXBElement<Serializable>(qname, clazz, value);
                    marshaller.marshal(element, out);
                }
                finally {
                    currentThread.setContextClassLoader(cl);
                }
                return new EventImpl(qname, out.toString());
            }
            catch (JAXBException e) {
                // maybe there is no valid jaxb binding
                // TODO wsrp:eventHandlingFailed
                logger.error("Event handling failed", e);
            }
            catch (FactoryConfigurationError e) {
                logger.warn(e.getMessage(), e);
            }
        }
        return null;
    }

    private boolean isDeclaredAsPublishingEvent(QName qname) {
        final PortletDefinition portletDescriptor = this.portletWindow.getPortletDefinition();
        final List<? extends EventDefinitionReference> events = portletDescriptor.getSupportedPublishingEvents();
        
        if (events != null) {
            final PortletApplicationDefinition application = portletDescriptor.getApplication();
            final String defaultNamespace = application.getDefaultNamespace();
            for (final EventDefinitionReference ref : events) {
                final QName name = ref.getQualifiedName(defaultNamespace);
                if (name == null) {
                    continue;
                }
                if (qname.equals(name)) {
                    return true;
                }
            }
        }
        return false;
    }

    private boolean isValueInstanceOfDefinedClass(QName qname, Serializable value) {
        final PortletDefinition portletDefinition = this.portletWindow.getPortletDefinition();
        final PortletApplicationDefinition app = portletDefinition.getApplication();
        final List<? extends EventDefinition> events = app.getEventDefinitions();
        if (events != null) {
            final String defaultNamespace = app.getDefaultNamespace();
            
            for (final EventDefinition eventDefinition : events) {
                if (eventDefinition.getQName() != null) {
                    if (eventDefinition.getQName().equals(qname)) {
                        final Class<? extends Serializable> valueClass = value.getClass();
                        return valueClass.getName().equals(eventDefinition.getValueType());
                    }
                }
                else {
                    final QName tmp = new QName(defaultNamespace, eventDefinition.getName());
                    if (tmp.equals(qname)) {
                        final Class<? extends Serializable> valueClass = value.getClass();
                        return valueClass.getName().equals(eventDefinition.getValueType());
                    }
                }
            }
        }
        // event not declared
        return true;
    }

}
