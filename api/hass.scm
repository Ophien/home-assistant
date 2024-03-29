(define-module (hass-services-api)
    #:export
    (
        hass-call-service
        hass-get-available-services
        hass-set-token
        hass-set-server-address
        hass-get-all-entities-and-services
    )
)

(use-modules
    (web client)
    (ice-9 receive)
    (ice-9 iconv)
    (json)
)

"
    # GET STARTED

        In order to use this module you need a running Home Assistant Server and an Access token. 
        Also, you need some smart devices to control.

    # HOME ASSISTANT SCHEME API
        This module allows to call for the Home Assistant services to all registered devices.
        
        (hass-call-service domain entity service)

        ```
            * Call to the Home Assistant server to the aforementioned domain, entity, and service.

            Params:

                domain: a string specifying the domain of your service, example \"light\" is a domain that incorporate all lights.
                entity: is a string specifying the entity name of your service call. For example, \"light.office\", in this case only the word \"office\" is the entity name.
                        in other words, the word after the \".\" of your entity_id in the home assistant server is your entity name.
                service: the service name to be called. For example, \"turn_on\" is a service name from the light domain that turn on a specified light.

            Example call:

                (hass-call-service  \"light\" \"office\" \"turn_on\")        
        ```

        (hass-get-available-services) - this function prints on the terminal all the available services from your home assistant server.
        
        (hass-set-token value)

        ```
            * this function allows you to set the access token for your home assistant server.

            Params:

                value: a name preceeded by ' that specifies your access token created in your home assistant server.

            Example call:

                (hass-set-token 'IUSBuifhafAShIUFH298714oiuwnfsdoh(HOFH2891hfoisnda982398.OSIF9uh9rh198)
        ```
        
        (hass-set-server-address hass-server-ip-address #:hass-server-port)

        ```
            * allows to set the IP address for your home assistant server.

            Params:

                hass-server-ip-address: string containing the server ip address
                hass-server-port: string containing the server port. Default value is \"8123\"

            Example call:

                (hass-set-server-address \"192.168.1.254\" #:hass-server-port \"8123\")
        ```

        (hass-get-all-entities-and-services)

        ```
            * returns an association list with all entities and their available services from your home assistant server
        ```
"

;;; (hass-server-address)
;;; Home Assistant server address.
(define hass-server-address
    "http://0.0.0.0:8123"
)

;;; (hass-token)
;;; Home Assistant access token.
(define hass-token 
	'none
)

;;; (hass-set-server-address)
;;; Allows to set your Home Assistant server address and port.
(define* (hass-set-server-address 
		hass-server-ip-address 
		#:key 
			(hass-server-port "8123"))
    (set! hass-server-address 
	(format #f "http://~a:~a" hass-server-ip-address hass-server-port)
    )
)

(define (hass-set-token value)
    (set! hass-token value)
)

;;; (hass-current-token)
;;; Returns the token that is currently set
(define (hass-current-token)
    hass-token
)

;;; (hass-build-service-call)
;;; Builds a string containing a service call to your Home Assistant server.
(define (hass-build-service-call domain service)
    (format #f "~a/api/services/~a/~a" hass-server-address domain service)
)

;;; (hass-rest-header)
;;; Generates a valid header for the service call through the Home Assistant REST API.
(define (hass-rest-header)
    (list
        (list 'content-type 'application/json)
        (list 'authorization 'Bearer hass-token)
    )
)

;;; (hass-call-service)
;;; Calls for a specified entity service fom a domain.
(define (hass-call-service domain entity service)
    (begin
        (http-post 
            (hass-build-service-call domain service)
            #:body (format #f "{\"entity_id\": \"~a.~a\"}" domain entity)
            #:headers (hass-rest-header)
        )
    )
)

;;; (hass-get-available-services)
;;; Get all available services from your Home Assistant server and returns a json file containing all available services.
(define (hass-get-available-services)
    (begin
        (bytevector->string 
            (receive (head response)
                (http-get 
                    (format "~a/api/services" hass-server-address)
                    #:headers (hass-rest-header)
                )       
                response
            )
            "utf8"
        )
    )
)

;;; (hass-get-available-entities)
;;; Get all available services from your Home Assistant server and returns a json file containing all available entities and their states.
(define (hass-get-available-entities)
    (begin
        (bytevector->string 
            (receive (head response)
                (http-get 
                    (format #f "~a/api/states" hass-server-address)
                    #:headers (hass-rest-header)
                )       
                response
            )
            "utf8"
        )
    )
)

;;; (hass-get-domain-from-entityid)
;;; return the domain from the complete entity id
(define (hass-get-domain-from-entityid entity-id)
    (list-ref (string-split entity-id #\.) 0)
)

;;; (hass-get-entity-from-entityid)
;;; return the entity from the complete entity id
(define (hass-get-entity-from-entityid entity-id)
    (list-ref (string-split entity-id #\.) 1)
)

;;; (hass-get-all-entities)
;;; get all entities from the hass server
(define* (hass-get-all-entities)
    (let*
        (
            (entities-json-obj (json-string->scm (hass-get-available-entities)))
            (entities-ids '())
        )
        (map
            (lambda(entity)
                (let*
                    (
                        (entity-id (assoc-ref entity "entity_id"))
                        (entity (hass-get-entity-from-entityid entity-id))
                        (domain (hass-get-domain-from-entityid entity-id))
                    )
                    (set! entities-ids 
                        (append entities-ids 
                            (list
                                (list domain entity)
                            )
                        )
                    )
                )
            )
            (array->list entities-json-obj)
        )
        entities-ids
    )
)

;;; (hass-get-all-domains)
;;; get all entities from the hass server
(define* (hass-get-all-domains-services)
    (let*
        (
            (services-json-obj (json-string->scm (hass-get-available-services)))
            (services-ids '())
        )
        (map
            (lambda(entity)
                (let*
                    (
                        (domain (assoc-ref entity "domain"))
                        (services (assoc-ref entity "services"))
                        (filtered-services (hass-filter-services services))
                    )
                    (set! services-ids 
                        (acons domain filtered-services services-ids)
                    )
                )
            )
            (array->list services-json-obj)
        )
        services-ids 
    )
)

;;; (hass-filter-services)
;;; used to get only the service name given a domain
(define* (hass-filter-services services)
    (let*
        (
            (output-list '())
        )
        (map
            (lambda (el)
                (set! output-list (append output-list (list(list-ref el 0))))
            )
            services
        )
        output-list
    )
)

;;; (hass-get-all-entities-and-services)
;;; get all services provided by hass for each entity
(define* (hass-get-all-entities-and-services)
    (let*
        (
            (all-entities (hass-get-all-entities))
            (all-services (hass-get-all-domains-services))
            (output-list '())
        )
        (map
            (lambda (el)
                (let*
                    (
                        (entity (list-ref el 1))
                        (domain (list-ref el 0))
                        (services-list (assoc-ref all-services domain))
                        (entity-s-list '())
                    )
                    (set! entity-s-list (acons 'entity entity entity-s-list))
                    (set! entity-s-list (acons 'domain domain entity-s-list))
                    (set! entity-s-list (acons 'services services-list entity-s-list))
                    (set! output-list (append output-list (list entity-s-list)))
                )
            )
            all-entities
        )
        output-list
    )
)

