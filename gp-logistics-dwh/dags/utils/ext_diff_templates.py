TEMPLATES = {

    'customers': r"""
DROP EXTERNAL TABLE IF EXISTS ext.customers_diff;
CREATE READABLE EXTERNAL TABLE ext.customers_diff (
        customer_id varchar(16),
        customer_name varchar(150),
        customer_type varchar(50),
        credit_terms_days integer,
        primary_freight_type varchar(50),
        account_status varchar(30),
        contract_start_date date,
        annual_revenue_potential numeric(14,2),
        is_deleted varchar(1),
        created_at timestamp,
        updated_at timestamp
) LOCATION ('pxf://customers?PROFILE=JDBC&SERVER=pgsrc')
FORMAT 'CUSTOM' (FORMATTER='pxfwritable_import');
""",

    'drivers': r"""
DROP EXTERNAL TABLE IF EXISTS ext.drivers_diff;
CREATE READABLE EXTERNAL TABLE ext.drivers_diff (
        driver_id varchar(16),
        first_name varchar(60),
        last_name varchar(60),
        hire_date date,
        termination_date date,
        license_number varchar(50),
        license_state varchar(10),
        date_of_birth date,
        home_terminal varchar(60),
        employment_status varchar(30),
        cdl_class varchar(10),
        years_experience integer,
        is_deleted varchar(1),
        created_at timestamp,
        updated_at timestamp
) LOCATION ('pxf://drivers?PROFILE=JDBC&SERVER=pgsrc')
FORMAT 'CUSTOM' (FORMATTER='pxfwritable_import');
""",

    'trucks': r"""
DROP EXTERNAL TABLE IF EXISTS ext.trucks_diff;
CREATE READABLE EXTERNAL TABLE ext.trucks_diff (
        truck_id varchar(16),
        unit_number varchar(20),
        make varchar(50),
        model_year integer,
        vin varchar(20),
        acquisition_date date,
        acquisition_mileage numeric(12,1),
        fuel_type varchar(30),
        tank_capacity_gallons numeric(8,2),
        status varchar(30),
        home_terminal varchar(60),
        is_deleted varchar(1),
        created_at timestamp,
        updated_at timestamp
) LOCATION ('pxf://trucks?PROFILE=JDBC&SERVER=pgsrc')
FORMAT 'CUSTOM' (FORMATTER='pxfwritable_import');
""",

    'trailers': r"""
DROP EXTERNAL TABLE IF EXISTS ext.trailers_diff;
CREATE READABLE EXTERNAL TABLE ext.trailers_diff (
        trailer_id varchar(16),
        trailer_number varchar(20),
        trailer_type varchar(40),
        length_feet integer,
        model_year integer,
        vin varchar(20),
        acquisition_date date,
        status varchar(30),
        current_location varchar(80),
        is_deleted varchar(1),
        created_at timestamp,
        updated_at timestamp
) LOCATION ('pxf://trailers?PROFILE=JDBC&SERVER=pgsrc')
FORMAT 'CUSTOM' (FORMATTER='pxfwritable_import');
""",

    'facilities': r"""
DROP EXTERNAL TABLE IF EXISTS ext.facilities_diff;
CREATE READABLE EXTERNAL TABLE ext.facilities_diff (
        facility_id varchar(16),
        facility_name varchar(150),
        facility_type varchar(50),
        city varchar(80),
        state varchar(10),
        latitude numeric(9,6),
        longitude numeric(9,6),
        dock_doors integer,
        operating_hours varchar(40),
        is_deleted varchar(1),
        created_at timestamp,
        updated_at timestamp
) LOCATION ('pxf://facilities?PROFILE=JDBC&SERVER=pgsrc')
FORMAT 'CUSTOM' (FORMATTER='pxfwritable_import');
""",

    'routes': r"""
DROP EXTERNAL TABLE IF EXISTS ext.routes_diff;
CREATE READABLE EXTERNAL TABLE ext.routes_diff (
        route_id varchar(16),
        origin_city varchar(80),
        origin_state varchar(10),
        destination_city varchar(80),
        destination_state varchar(10),
        typical_distance_miles numeric(10,2),
        base_rate_per_mile numeric(8,3),
        fuel_surcharge_rate numeric(8,3),
        typical_transit_days integer,
        is_deleted varchar(1),
        created_at timestamp,
        updated_at timestamp
) LOCATION ('pxf://routes?PROFILE=JDBC&SERVER=pgsrc')
FORMAT 'CUSTOM' (FORMATTER='pxfwritable_import');
""",

    'loads': r"""
DROP EXTERNAL TABLE IF EXISTS ext.loads_diff;
CREATE READABLE EXTERNAL TABLE ext.loads_diff (
        load_id varchar(20),
        customer_id varchar(16),
        route_id varchar(16),
        load_date date,
        load_type varchar(40),
        weight_lbs numeric(12,2),
        pieces integer,
        revenue numeric(14,2),
        fuel_surcharge numeric(14,2),
        accessorial_charges numeric(14,2),
        load_status varchar(30),
        booking_type varchar(30),
        is_deleted varchar(1),
        created_at timestamp,
        updated_at timestamp
) LOCATION ('pxf://loads?PROFILE=JDBC&SERVER=pgsrc')
FORMAT 'CUSTOM' (FORMATTER='pxfwritable_import');
""",

    'trips': r"""
DROP EXTERNAL TABLE IF EXISTS ext.trips_diff;
CREATE READABLE EXTERNAL TABLE ext.trips_diff (
        trip_id varchar(20),
        load_id varchar(20),
        driver_id varchar(16),
        truck_id varchar(16),
        trailer_id varchar(16),
        dispatch_date date,
        actual_distance_miles numeric(10,2),
        actual_duration_hours numeric(8,2),
        fuel_gallons_used numeric(10,2),
        average_mpg numeric(6,2),
        idle_time_hours numeric(8,2),
        trip_status varchar(30),
        is_deleted varchar(1),
        created_at timestamp,
        updated_at timestamp
) LOCATION ('pxf://trips?PROFILE=JDBC&SERVER=pgsrc')
FORMAT 'CUSTOM' (FORMATTER='pxfwritable_import');
""",

    'delivery_events': r"""
DROP EXTERNAL TABLE IF EXISTS ext.delivery_events_diff;
CREATE READABLE EXTERNAL TABLE ext.delivery_events_diff (
        event_id varchar(20),
        load_id varchar(20),
        trip_id varchar(20),
        event_type varchar(40),
        facility_id varchar(16),
        scheduled_datetime timestamp,
        actual_datetime timestamp,
        detention_minutes integer,
        on_time_flag boolean,
        location_city varchar(80),
        location_state varchar(10),
        is_deleted varchar(1),
        created_at timestamp,
        updated_at timestamp
) LOCATION ('pxf://delivery_events?PROFILE=JDBC&SERVER=pgsrc')
FORMAT 'CUSTOM' (FORMATTER='pxfwritable_import');
""",

    'fuel_purchases': r"""
DROP EXTERNAL TABLE IF EXISTS ext.fuel_purchases_diff;
CREATE READABLE EXTERNAL TABLE ext.fuel_purchases_diff (
        fuel_purchase_id varchar(20),
        trip_id varchar(20),
        truck_id varchar(16),
        driver_id varchar(16),
        purchase_date timestamp,
        location_city varchar(80),
        location_state varchar(10),
        gallons numeric(10,2),
        price_per_gallon numeric(8,3),
        total_cost numeric(14,2),
        fuel_card_number varchar(30),
        is_deleted varchar(1),
        created_at timestamp,
        updated_at timestamp
) LOCATION ('pxf://fuel_purchases?PROFILE=JDBC&SERVER=pgsrc')
FORMAT 'CUSTOM' (FORMATTER='pxfwritable_import');
""",

    'maintenance_records': r"""
DROP EXTERNAL TABLE IF EXISTS ext.maintenance_records_diff;
CREATE READABLE EXTERNAL TABLE ext.maintenance_records_diff (
        maintenance_id varchar(20),
        truck_id varchar(16),
        maintenance_date date,
        maintenance_type varchar(50),
        odometer_reading numeric(12,1),
        labor_hours numeric(8,2),
        labor_cost numeric(14,2),
        parts_cost numeric(14,2),
        total_cost numeric(14,2),
        facility_location varchar(80),
        downtime_hours numeric(8,2),
        service_description varchar(255),
        is_deleted varchar(1),
        created_at timestamp,
        updated_at timestamp
) LOCATION ('pxf://maintenance_records?PROFILE=JDBC&SERVER=pgsrc')
FORMAT 'CUSTOM' (FORMATTER='pxfwritable_import');
""",

    'safety_incidents': r"""
DROP EXTERNAL TABLE IF EXISTS ext.safety_incidents_diff;
CREATE READABLE EXTERNAL TABLE ext.safety_incidents_diff (
        incident_id varchar(20),
        trip_id varchar(20),
        truck_id varchar(16),
        driver_id varchar(16),
        incident_date timestamp,
        incident_type varchar(50),
        location_city varchar(80),
        location_state varchar(10),
        at_fault_flag boolean,
        injury_flag boolean,
        vehicle_damage_cost numeric(14,2),
        cargo_damage_cost numeric(14,2),
        claim_amount numeric(14,2),
        preventable_flag boolean,
        description varchar(255),
        is_deleted varchar(1),
        created_at timestamp,
        updated_at timestamp
) LOCATION ('pxf://safety_incidents?PROFILE=JDBC&SERVER=pgsrc')
FORMAT 'CUSTOM' (FORMATTER='pxfwritable_import');
""",

}

BUSINESS_COLUMNS = {
    'customers': ['customer_id', 'customer_name', 'customer_type', 'credit_terms_days', 'primary_freight_type', 'account_status', 'contract_start_date', 'annual_revenue_potential'],
    'drivers': ['driver_id', 'first_name', 'last_name', 'hire_date', 'termination_date', 'license_number', 'license_state', 'date_of_birth', 'home_terminal', 'employment_status', 'cdl_class', 'years_experience'],
    'trucks': ['truck_id', 'unit_number', 'make', 'model_year', 'vin', 'acquisition_date', 'acquisition_mileage', 'fuel_type', 'tank_capacity_gallons', 'status', 'home_terminal'],
    'trailers': ['trailer_id', 'trailer_number', 'trailer_type', 'length_feet', 'model_year', 'vin', 'acquisition_date', 'status', 'current_location'],
    'facilities': ['facility_id', 'facility_name', 'facility_type', 'city', 'state', 'latitude', 'longitude', 'dock_doors', 'operating_hours'],
    'routes': ['route_id', 'origin_city', 'origin_state', 'destination_city', 'destination_state', 'typical_distance_miles', 'base_rate_per_mile', 'fuel_surcharge_rate', 'typical_transit_days'],
    'loads': ['load_id', 'customer_id', 'route_id', 'load_date', 'load_type', 'weight_lbs', 'pieces', 'revenue', 'fuel_surcharge', 'accessorial_charges', 'load_status', 'booking_type'],
    'trips': ['trip_id', 'load_id', 'driver_id', 'truck_id', 'trailer_id', 'dispatch_date', 'actual_distance_miles', 'actual_duration_hours', 'fuel_gallons_used', 'average_mpg', 'idle_time_hours', 'trip_status'],
    'delivery_events': ['event_id', 'load_id', 'trip_id', 'event_type', 'facility_id', 'scheduled_datetime', 'actual_datetime', 'detention_minutes', 'on_time_flag', 'location_city', 'location_state'],
    'fuel_purchases': ['fuel_purchase_id', 'trip_id', 'truck_id', 'driver_id', 'purchase_date', 'location_city', 'location_state', 'gallons', 'price_per_gallon', 'total_cost', 'fuel_card_number'],
    'maintenance_records': ['maintenance_id', 'truck_id', 'maintenance_date', 'maintenance_type', 'odometer_reading', 'labor_hours', 'labor_cost', 'parts_cost', 'total_cost', 'facility_location', 'downtime_hours', 'service_description'],
    'safety_incidents': ['incident_id', 'trip_id', 'truck_id', 'driver_id', 'incident_date', 'incident_type', 'location_city', 'location_state', 'at_fault_flag', 'injury_flag', 'vehicle_damage_cost', 'cargo_damage_cost', 'claim_amount', 'preventable_flag', 'description'],
}
