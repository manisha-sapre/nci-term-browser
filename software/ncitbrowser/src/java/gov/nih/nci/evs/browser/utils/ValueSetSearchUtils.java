package gov.nih.nci.evs.browser.utils;


import java.util.*;
import java.io.*;
import java.net.*;
import org.LexGrid.LexBIG.caCore.interfaces.*;
import org.LexGrid.LexBIG.LexBIGService.*;
import org.LexGrid.LexBIG.Impl.*;

import gov.nih.nci.system.client.*;
import gov.nih.nci.evs.security.*;

import org.apache.log4j.*;

import org.LexGrid.LexBIG.caCore.interfaces.LexEVSDistributed;
import org.lexgrid.valuesets.LexEVSValueSetDefinitionServices;


import gov.nih.nci.system.client.ApplicationServiceProvider;

import org.LexGrid.LexBIG.DataModel.Collections.AbsoluteCodingSchemeVersionReferenceList;
import org.LexGrid.LexBIG.Utility.Constructors;
import org.LexGrid.LexBIG.Utility.Iterators.ResolvedConceptReferencesIterator;
import org.LexGrid.LexBIG.caCore.interfaces.LexEVSDistributed;
import org.LexGrid.naming.Mappings;
import org.LexGrid.naming.SupportedCodingScheme;
import org.LexGrid.util.PrintUtility;
import org.LexGrid.valueSets.DefinitionEntry;
import org.LexGrid.valueSets.EntityReference;
import org.LexGrid.valueSets.PropertyMatchValue;
import org.LexGrid.valueSets.PropertyReference;
import org.LexGrid.valueSets.ValueSetDefinition;
import org.LexGrid.valueSets.types.DefinitionOperator;
import org.lexgrid.valuesets.LexEVSValueSetDefinitionServices;
import org.lexgrid.valuesets.dto.ResolvedValueSetDefinition;
import org.LexGrid.valueSets.ValueSetDefinitionReference;
import org.LexGrid.commonTypes.EntityDescription;
import org.LexGrid.valueSets.CodingSchemeReference;

import org.LexGrid.LexBIG.DataModel.Core.ResolvedConceptReference;

import org.LexGrid.LexBIG.DataModel.Collections.SortOptionList;
import org.LexGrid.LexBIG.Exceptions.LBException;

import org.lexgrid.valuesets.dto.ResolvedValueSetCodedNodeSet;


import org.LexGrid.LexBIG.DataModel.Core.AbsoluteCodingSchemeVersionReference;
import org.LexGrid.LexBIG.DataModel.Collections.AbsoluteCodingSchemeVersionReferenceList;


import org.LexGrid.LexBIG.DataModel.Core.ConceptReference;
import org.LexGrid.codingSchemes.CodingScheme;
import org.LexGrid.LexBIG.DataModel.Core.CodingSchemeVersionOrTag;
import org.LexGrid.LexBIG.DataModel.Core.types.CodingSchemeVersionStatus;
import org.LexGrid.LexBIG.DataModel.Core.CodingSchemeSummary;

import org.LexGrid.LexBIG.DataModel.InterfaceElements.CodingSchemeRendering;

import org.LexGrid.LexBIG.Exceptions.LBInvocationException;
import org.LexGrid.LexBIG.DataModel.Collections.CodingSchemeRenderingList;

import org.lexgrid.valuesets.dto.ResolvedValueSetCodedNodeSet;
import org.LexGrid.LexBIG.DataModel.Collections.AbsoluteCodingSchemeVersionReferenceList;
import org.LexGrid.LexBIG.DataModel.Collections.LocalNameList;

import org.LexGrid.LexBIG.LexBIGService.CodedNodeSet.PropertyType;
import org.LexGrid.LexBIG.DataModel.Collections.ConceptReferenceList;
import org.LexGrid.LexBIG.DataModel.Core.ConceptReference;

import org.lexgrid.resolvedvalueset.LexEVSResolvedValueSetService;
import org.lexgrid.resolvedvalueset.impl.LexEVSResolvedValueSetServiceImpl;


public class ValueSetSearchUtils
{
	private static Logger _logger = Logger.getLogger(ValueSetSearchUtils.class);

	protected static void displayRef(int count, ResolvedConceptReference ref){
		System.out.println("(" + count + ") " + ref.getConceptCode() + " (" + ref.getEntityDescription().getContent()
		    + ") namespace: " + ref.getCodeNamespace() + ", coding scheme: " + ref.getCodingSchemeName() + ", version: " + ref.getCodingSchemeVersion());
	}


    private String findBestContainsAlgorithm(String matchText) {
        if (matchText == null)
            return "nonLeadingWildcardLiteralSubString";
        matchText = matchText.trim();
        if (matchText.length() == 0)
            return "nonLeadingWildcardLiteralSubString"; // or null
        if (matchText.length() > 1)
            return "nonLeadingWildcardLiteralSubString";
        char ch = matchText.charAt(0);
        if (Character.isDigit(ch))
            return "literal";
        else if (Character.isLetter(ch))
            return "LuceneQuery";
        else
            return "literalContains";
    }


      public static AbsoluteCodingSchemeVersionReferenceList getEntireAbsoluteCodingSchemeVersionReferenceList() {
        boolean includeInactive = false;
        AbsoluteCodingSchemeVersionReferenceList list = new AbsoluteCodingSchemeVersionReferenceList();
        try {
            LexBIGService lbSvc = RemoteServerUtil.createLexBIGService();
            if (lbSvc == null) {
                _logger
                    .warn("WARNING: Unable to connect to instantiate LexBIGService ???");
                return null;
            }

            CodingSchemeRenderingList csrl = null;
            try {
                csrl = lbSvc.getSupportedCodingSchemes();

            } catch (LBInvocationException ex) {
                ex.printStackTrace();
                _logger.error("lbSvc.getSupportedCodingSchemes() FAILED..."
                    + ex.getCause());
                return null;
            }

            CodingSchemeRendering[] csrs = csrl.getCodingSchemeRendering();
            for (int i = 0; i < csrs.length; i++) {
                int j = i + 1;
                CodingSchemeRendering csr = csrs[i];
                CodingSchemeSummary css = csr.getCodingSchemeSummary();
                String formalname = css.getFormalName();
                Boolean isActive = null;
                /*
                if (csr == null) {
                    _logger.warn("\tcsr == null???");
                } else
                */

                if (csr.getRenderingDetail() == null) {
                    _logger.warn("\tcsr.getRenderingDetail() == null");
                } else if (csr.getRenderingDetail().getVersionStatus() == null) {
                    _logger
                        .warn("\tcsr.getRenderingDetail().getVersionStatus() == null");
                } else {

                    isActive =
                        csr.getRenderingDetail().getVersionStatus().equals(
                            CodingSchemeVersionStatus.ACTIVE);
                }

                String representsVersion = css.getRepresentsVersion();
                _logger.debug("(" + j + ") " + formalname + "  version: "
                    + representsVersion);
                _logger.debug("\tActive? " + isActive);

                if ((includeInactive && isActive == null)
                    || (isActive != null && isActive.equals(Boolean.TRUE))
                    || (includeInactive && (isActive != null && isActive
                        .equals(Boolean.FALSE)))) {
                    // nv_vec.add(value);
                    // csnv2codingSchemeNameMap.put(value, formalname);
                    // csnv2VersionMap.put(value, representsVersion);

                    // KLO 010810
                    CodingSchemeVersionOrTag vt =
                        new CodingSchemeVersionOrTag();
                    vt.setVersion(representsVersion);

                    try {
                        CodingScheme cs =
                            lbSvc.resolveCodingScheme(formalname, vt);

                        AbsoluteCodingSchemeVersionReference acsvr = new AbsoluteCodingSchemeVersionReference();
                        acsvr.setCodingSchemeURN(cs.getCodingSchemeURI());
                        acsvr.setCodingSchemeVersion(representsVersion);

                        list.addAbsoluteCodingSchemeVersionReference(acsvr);

                    } catch (Exception ex) {
						ex.printStackTrace();
                    }

                } else {
                    _logger.error("\tWARNING: setCodingSchemeMap discards "
                        + formalname);
                    _logger.error("\t\trepresentsVersion " + representsVersion);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            // return null;
        }
        return list;
    }

/*
      public static Boolean isCodeInValueSet(String code, String codingScheme, String vsd_uri) {
		  Boolean retval = null;
		  try {
				String URL = "http://ncias-q541-v.nci.nih.gov:29080/lexevsapi60";
				URL = "http://localhost:19280/lexevsapi60";
				LexEVSValueSetDefinitionServices vds = RemoteServerUtil.getLexEVSValueSetDefinitionServices(URL);

                java.lang.String valueSetDefinitionRevisionId = null;
                AbsoluteCodingSchemeVersionReferenceList csVersionList = getEntireAbsoluteCodingSchemeVersionReferenceList();
                java.lang.String csVersionTag = null;

                ResolvedValueSetCodedNodeSet rvs_cns = vds.getCodedNodeSetForValueSetDefinition(
					 new URI(vsd_uri),
                     valueSetDefinitionRevisionId,
                     csVersionList,
                     csVersionTag);

                if (rvs_cns == null) return false;
                CodedNodeSet cns = rvs_cns.getCodedNodeSet();
                ConceptReference conceptReference = new ConceptReference();
                conceptReference.setConceptCode(code);
                if (codingScheme != null) {
					conceptReference.setCodingSchemeName(codingScheme);
				}
                java.lang.Boolean bool_obj = cns.isCodeInSet(conceptReference);
                return bool_obj;

		  } catch (Exception ex) {
				ex.printStackTrace();
		  }

          return retval;
	  }
*/


    public ResolvedConceptReferencesIteratorWrapper searchByCode(
        String vsd_uri, String matchText, int maxToReturn) {

		if (matchText == null) return null;
        //String matchText0 = matchText;
        String matchAlgorithm0 = "exactMatch";
        //matchText0 = matchText0.trim();

        _logger.debug("searchByCode ..." + matchText);
        //long ms = System.currentTimeMillis(), delay = 0;
        long tnow = System.currentTimeMillis();
        long total_delay = 0;
        boolean debug_flag = false;

        boolean preprocess = true;
        //if (matchText == null || matchText.length() == 0) {
		if (matchText.length() == 0) {
            return null;
        }

        matchText = matchText.trim();
        CodedNodeSet cns = null;
        ResolvedConceptReferencesIterator iterator = null;
        try {
			LexEVSValueSetDefinitionServices vsd_service = RemoteServerUtil.getLexEVSValueSetDefinitionServices();
            if (vsd_service == null) {
                _logger.warn("vsd_service = null");
                return null;
            }
            java.lang.String valueSetDefinitionRevisionId = null;
            AbsoluteCodingSchemeVersionReferenceList csVersionList = null;

            String csVersionTag = null;

            ResolvedValueSetCodedNodeSet rvs_cns = vsd_service.getCodedNodeSetForValueSetDefinition(new URI(vsd_uri),
                  valueSetDefinitionRevisionId, csVersionList, csVersionTag);

            if (rvs_cns == null) {
                return null;
            }

            cns = rvs_cns.getCodedNodeSet();
            if (cns == null) {
                return null;
            }

            ConceptReferenceList codeList = new ConceptReferenceList();
            ConceptReference cr = new ConceptReference();
            cr.setConceptCode(matchText);
            codeList.addConceptReference(cr);

            cns = cns.restrictToCodes(codeList);

            SortOptionList sortOptions = null;
            LocalNameList filterOptions = null;
            LocalNameList propertyNames = null;
            boolean resolveObjects = false;
            CodedNodeSet.PropertyType[] propertyTypes = null;

            iterator = cns.resolve(sortOptions, filterOptions, propertyNames, propertyTypes, resolveObjects);

		} catch (Exception ex) {
			ex.printStackTrace();
			return null;
		}

        total_delay = System.currentTimeMillis() - tnow;
        _logger.debug("Total search delay: (millisec.): " + total_delay);
        return new ResolvedConceptReferencesIteratorWrapper(iterator);

    }




    public ResolvedConceptReferencesIteratorWrapper searchByName(
        String vsd_uri, String matchText, String matchAlgorithm, int maxToReturn) {

		if (matchText == null) return null;

        //String matchText0 = matchText;
        String matchAlgorithm0 = matchAlgorithm;
        //matchText0 = matchText0.trim();

        _logger.debug("searchByName ..." + matchText);

        //long ms = System.currentTimeMillis(), delay = 0;
        long tnow = System.currentTimeMillis();
        long total_delay = 0;
        boolean debug_flag = false;

        boolean preprocess = true;
        if (matchText.length() == 0) {
            return null;
        }

        matchText = matchText.trim();
        if (matchAlgorithm.compareToIgnoreCase("contains") == 0)
        {
            matchAlgorithm = findBestContainsAlgorithm(matchText);
        }

        CodedNodeSet cns = null;
        ResolvedConceptReferencesIterator iterator = null;
        try {
			LexEVSValueSetDefinitionServices vsd_service = RemoteServerUtil.getLexEVSValueSetDefinitionServices();
            if (vsd_service == null) {
                _logger.warn("vsd_service = null");
                return null;
            }
            java.lang.String valueSetDefinitionRevisionId = null;
            AbsoluteCodingSchemeVersionReferenceList csVersionList = null;
            /*
            Vector cs_ref_vec = DataUtils.getCodingSchemeReferencesInValueSetDefinition(vsd_uri, "PRODUCTION");
            if (cs_ref_vec != null) csVersionList = DataUtils.vector2CodingSchemeVersionReferenceList(cs_ref_vec);
            */

            String csVersionTag = null;

            ResolvedValueSetCodedNodeSet rvs_cns = vsd_service.getCodedNodeSetForValueSetDefinition(new URI(vsd_uri),
                  valueSetDefinitionRevisionId, csVersionList, csVersionTag);

            if (rvs_cns == null) {
                return null;
            }

            cns = rvs_cns.getCodedNodeSet();
            if (cns == null) {
                return null;
            }

            CodedNodeSet.SearchDesignationOption option = null;
            String language = null;
            cns = cns.restrictToAnonymous(CodedNodeSet.AnonymousOption.NON_ANONYMOUS_ONLY);
            cns = cns.restrictToMatchingDesignations(matchText, option, matchAlgorithm, language);
            SortOptionList sortOptions = null;
            LocalNameList filterOptions = null;
            LocalNameList propertyNames = null;
            CodedNodeSet.PropertyType[] propertyTypes = null;
            boolean resolveObjects = false;
            iterator = cns.resolve(sortOptions, filterOptions, propertyNames, propertyTypes, resolveObjects);

		} catch (Exception ex) {
			ex.printStackTrace();
			return null;
		}

        total_delay = System.currentTimeMillis() - tnow;
        _logger.debug("Total search delay: (millisec.): " + total_delay);
        return new ResolvedConceptReferencesIteratorWrapper(iterator);

    }


    private CodedNodeSet.PropertyType[] getAllPropertyTypes() {
        CodedNodeSet.PropertyType[] propertyTypes =
            new CodedNodeSet.PropertyType[4];
        propertyTypes[0] = PropertyType.COMMENT;
        propertyTypes[1] = PropertyType.DEFINITION;
        propertyTypes[2] = PropertyType.GENERIC;
        propertyTypes[3] = PropertyType.PRESENTATION;
        return propertyTypes;
    }

    private CodedNodeSet.PropertyType[] getAllNonPresentationPropertyTypes() {
        CodedNodeSet.PropertyType[] propertyTypes =
            new CodedNodeSet.PropertyType[3];
        propertyTypes[0] = PropertyType.COMMENT;
        propertyTypes[1] = PropertyType.DEFINITION;
        propertyTypes[2] = PropertyType.GENERIC;
        return propertyTypes;
    }


    public ResolvedConceptReferencesIteratorWrapper searchByProperties(
        String vsd_uri, String matchText, boolean excludeDesignation, String matchAlgorithm, int maxToReturn) {
		if (matchText == null) return null;

        //String matchText0 = matchText;
        String matchAlgorithm0 = matchAlgorithm;
        //matchText0 = matchText0.trim();

        _logger.debug("searchByProperties ..." + matchText);

        //long ms = System.currentTimeMillis(), delay = 0;
        long tnow = System.currentTimeMillis();
        long total_delay = 0;
        boolean debug_flag = false;

        boolean preprocess = true;
        if (matchText.length() == 0) {
            return null;
        }

        matchText = matchText.trim();
        if (matchAlgorithm.compareToIgnoreCase("contains") == 0)
        {
            matchAlgorithm = findBestContainsAlgorithm(matchText);
        }
        CodedNodeSet cns = null;
        ResolvedConceptReferencesIterator iterator = null;
        try {
			LexEVSValueSetDefinitionServices vsd_service = RemoteServerUtil.getLexEVSValueSetDefinitionServices();
            if (vsd_service == null) {
                _logger.warn("vsd_service = null");
                return null;
            }
            java.lang.String valueSetDefinitionRevisionId = null;
            AbsoluteCodingSchemeVersionReferenceList csVersionList = null;
            /*
            Vector cs_ref_vec = DataUtils.getCodingSchemeReferencesInValueSetDefinition(vsd_uri, "PRODUCTION");
            if (cs_ref_vec != null) csVersionList = DataUtils.vector2CodingSchemeVersionReferenceList(cs_ref_vec);
            */
            String csVersionTag = null;

            ResolvedValueSetCodedNodeSet rvs_cns = vsd_service.getCodedNodeSetForValueSetDefinition(new URI(vsd_uri),
                  valueSetDefinitionRevisionId, csVersionList, csVersionTag);

            if (rvs_cns == null) {
                return null;
            }

            cns = rvs_cns.getCodedNodeSet();
            if (cns == null) {
                return null;
            }

            CodedNodeSet.SearchDesignationOption option = null;
            String language = null;
            cns = cns.restrictToAnonymous(CodedNodeSet.AnonymousOption.NON_ANONYMOUS_ONLY);
			LocalNameList propertyNames = new LocalNameList();
			CodedNodeSet.PropertyType[] propertyTypes = null;
			if (!excludeDesignation) {
				propertyTypes = getAllPropertyTypes();

			} else {
				propertyTypes = getAllNonPresentationPropertyTypes();
			}

			cns = cns.restrictToMatchingProperties(
						propertyNames, propertyTypes,
						matchText, matchAlgorithm, language);

            SortOptionList sortOptions = null;
            LocalNameList filterOptions = null;
            propertyNames = null;
            boolean resolveObjects = false;
            iterator = cns.resolve(sortOptions, filterOptions, propertyNames, propertyTypes, resolveObjects);

		} catch (Exception ex) {
			ex.printStackTrace();
			return null;
		}

        total_delay = System.currentTimeMillis() - tnow;
        _logger.debug("Total search delay: (millisec.): " + total_delay);
        return new ResolvedConceptReferencesIteratorWrapper(iterator);

    }


    public static Vector filterValueSetMetadata(Vector metadata_vec, String codingSchemeName) {
		if (codingSchemeName.compareTo("ALL") == 0) return metadata_vec;
		Vector w = new Vector();
        for (int i=0; i<metadata_vec.size(); i++) {
		    String vsd_str = (String) metadata_vec.elementAt(i);
		    Vector u = DataUtils.parseData(vsd_str);
		    String uri = (String) u.elementAt(1);
		    Vector cs_vec = DataUtils.getCodingSchemeURNsInValueSetDefinition(uri);

		    if (cs_vec.contains(codingSchemeName)) {
				w.add(vsd_str);
			}
		}
        return w;
	}


    public static boolean containsConceptInCodingScheme(String vsd_uri, String codingSchemeName) {
		if (codingSchemeName.compareTo("ALL") == 0) return true;
	    Vector cs_vec = DataUtils.getCodingSchemeURNsInValueSetDefinition(vsd_uri);
        if (cs_vec.contains(codingSchemeName)) return true;
        return false;
	}


	public static Vector getCodingSchemeVersionsByURN(String RVSCS_formalname) {
		if (RVSCS_formalname == null) return null;
		return DataUtils.getRVSCSVersionsByFormalName(RVSCS_formalname);
	}


/*
    public static Vector getCodingSchemeVersionsByURN(String urn) {
        try {
			Vector v = new Vector();
            LexBIGService lbSvc = RemoteServerUtil.createLexBIGService();
            if (lbSvc == null) {
                _logger
                    .warn("WARNING: Unable to connect to instantiate LexBIGService ???");
                return v;
            }
            CodingSchemeRenderingList csrl = null;
            try {
                csrl = lbSvc.getSupportedCodingSchemes();
            } catch (LBInvocationException ex) {
                ex.printStackTrace();
                _logger.error("lbSvc.getSupportedCodingSchemes() FAILED..."
                    + ex.getCause());
                return null;
            }
            CodingSchemeRendering[] csrs = csrl.getCodingSchemeRendering();
            for (int i = 0; i < csrs.length; i++) {
                int j = i + 1;
                CodingSchemeRendering csr = csrs[i];
                CodingSchemeSummary css = csr.getCodingSchemeSummary();
                Boolean isActive =
                        csr.getRenderingDetail().getVersionStatus().equals(
                            CodingSchemeVersionStatus.ACTIVE);

                if (isActive != null && isActive.equals(Boolean.TRUE)) {
                	String uri = css.getCodingSchemeURI();
                	String formalName = css.getFormalName();
                	String localName = css.getLocalName();

                	if (urn.compareTo(formalName) == 0 || urn.compareTo(localName) == 0 || urn.compareTo(uri) == 0 ) {
						String representsVersion = css.getRepresentsVersion();
						v.add(representsVersion);
					}
				}
			}
			return v;
		} catch (Exception ex) {
			ex.printStackTrace();
		}
		return null;
	}
*/

    public ResolvedConceptReferencesIteratorWrapper searchResolvedValueSetCodingSchemes(String checked_vocabularies,
        String matchText, String matchAlgorithm) {
		return searchResolvedValueSetCodingSchemes(checked_vocabularies, matchText, SimpleSearchUtils.BY_NAME, matchAlgorithm);
	}


    public ResolvedConceptReferencesIteratorWrapper searchResolvedValueSetCodingSchemes(String checked_vocabularies,
        String matchText, int searchOption, String matchAlgorithm) {
		ResolvedConceptReferencesIteratorWrapper wrapper = null;

long ms = System.currentTimeMillis();

		if (checked_vocabularies == null) return null;
		Vector selected_vocabularies = DataUtils.parseData(checked_vocabularies, ",");
		// find versions
		Vector schemes = new Vector();
		Vector versions = new Vector();
		for (int i=0; i<selected_vocabularies.size(); i++) {
			int k = i+1;
			String selected_vocabulary = (String) selected_vocabularies.elementAt(i);
			Vector u = getCodingSchemeVersionsByURN(selected_vocabulary);
			if (u != null) {
				for (int j=0; j<u.size(); j++) {
					String version = (String) u.elementAt(j);
					schemes.add(selected_vocabulary);
					versions.add(version);
				}
		    } else {
				//System.out.println("\tgetCodingSchemeVersionsByURN returns null ??? " + selected_vocabulary);
			}
		}

_logger.debug("\tComponent run time (ms) of searching for all resovled value set coding scheme versions: " + (System.currentTimeMillis() - ms));
System.out.println("\tComponent run time (ms) of searching for all resovled value set coding scheme versions: " + (System.currentTimeMillis() - ms));

		/*
		// performs search
		ResolvedConceptReferencesIteratorWrapper wrapper = null;
		if (SimpleSearchUtils.isSimpleSearchSupported(matchAlgorithm, SimpleSearchUtils.NAMES)) {
			try {
				wrapper = new SimpleSearchUtils().search(schemes, versions, matchText, searchOption, matchAlgorithm);

			} catch (Exception ex) {
				ex.printStackTrace();
			}
		} else {
			String source = "ALL";
			boolean ranking = false;
			int maxToReturn = -1;
			if (searchOption == SimpleSearchUtils.BY_NAME) {
				wrapper = new SearchUtils().searchByNameOrCode(
						schemes, versions, matchText,
						source, matchAlgorithm, ranking, maxToReturn, SearchUtils.SEARCH_BY_NAME_ONLY);
			} else {
				//071513
				wrapper = new SearchUtils().searchByNameOrCode(
						schemes, versions, matchText,
						source, matchAlgorithm, ranking, maxToReturn, SearchUtils.SEARCH_BY_CODE_ONLY);
			}
		}
		return wrapper;
		*/


        if (searchOption == SimpleSearchUtils.BY_NAME) {
			if (SimpleSearchUtils.isSimpleSearchSupported(matchAlgorithm, SimpleSearchUtils.NAMES)) {
				try {

_logger.debug("searchResolvedValueSetCodingSchemes by name using search extension -- " + matchText + ", " + matchAlgorithm);
System.out.println("searchResolvedValueSetCodingSchemes by name using search extension -- " + matchText + ", " + matchAlgorithm);

					wrapper = new SimpleSearchUtils().search(schemes, versions, matchText, searchOption, matchAlgorithm);


				} catch (Exception ex) {
					ex.printStackTrace();
				}
			} else {
				String source = "ALL";
				boolean ranking = false;
				int maxToReturn = -1;

_logger.debug("searchResolvedValueSetCodingSchemes by name using regular search API -- " + matchText + ", " + matchAlgorithm);
System.out.println("searchResolvedValueSetCodingSchemes by name using regular search API -- " + matchText + ", " + matchAlgorithm);

					wrapper = new SearchUtils().searchByNameOrCode(
							schemes, versions, matchText,
							source, matchAlgorithm, ranking, maxToReturn, SearchUtils.SEARCH_BY_NAME_ONLY);
			}

		} else if (searchOption == SimpleSearchUtils.BY_CODE) {
			if (SimpleSearchUtils.isSimpleSearchSupported(matchAlgorithm, SimpleSearchUtils.CODES)) {
				try {

_logger.debug("searchResolvedValueSetCodingSchemes by code using search extension -- " + matchText + ", " + matchAlgorithm);
System.out.println("searchResolvedValueSetCodingSchemes by code using search extension -- " + matchText + ", " + matchAlgorithm);

					wrapper = new SimpleSearchUtils().search(schemes, versions, matchText, searchOption, matchAlgorithm);

				} catch (Exception ex) {
					ex.printStackTrace();
				}
			} else {
				String source = "ALL";
				boolean ranking = false;
				int maxToReturn = -1;

_logger.debug("searchResolvedValueSetCodingSchemes by name using regular search API -- " + matchText + ", " + matchAlgorithm);
System.out.println("searchResolvedValueSetCodingSchemes by name using regular search API -- " + matchText + ", " + matchAlgorithm);

					wrapper = new SearchUtils().searchByNameOrCode(
							schemes, versions, matchText,
							source, matchAlgorithm, ranking, maxToReturn, SearchUtils.SEARCH_BY_CODE_ONLY);

			}
		}


_logger.debug("Run time (ms): " + (System.currentTimeMillis() - ms));
System.out.println("Run time (ms): " + (System.currentTimeMillis() - ms));


		return wrapper;
	}
}

