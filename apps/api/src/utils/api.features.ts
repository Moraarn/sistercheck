import { Query, SortOrder } from "mongoose";

// Define the structure of the query string
interface QueryString {
  page?: number;
  sort?: string;
  fields?: string;
  keyword?: string;
  limit?: number;
  skip?: number;
  from?: string;
  to?: string;
  order?: "asc" | "desc";
  [key: string]: any;
}

export interface IPagination {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
}

export interface IFilter {
  field: string;
  value: any;
  operator: "eq" | "gt" | "lt" | "gte" | "lte" | "contains" | "in" | "nin";
}

export interface IResponseOptions {
  pagination?: IPagination;
  filters?: IFilter[];
  sort?: {
    field: string;
    order: "asc" | "desc";
  };
  metadata?: Record<string, any>;
}

// Common search fields across different entities
const COMMON_SEARCH_FIELDS = [
  "title",
  "name",
  "firstName",
  "lastName",
  "username",
  "email",
  "phone",
  "description",
  "status",
  "type",
  "category",
  "location",
  "tags",
  "address",
  "city",
  "state",
  "country",
  "zip",
];

// type paginated data
export type PaginatedData<T> = {
  pagination: IPagination;
  filters: IFilter[];
  sort: {
    field: string;
    order: "asc" | "desc";
  };
  [key: string]: T[] | IPagination | IFilter[] | { field: string; order: "asc" | "desc" };
};

const PAGE_LIMIT = 10; // Default number of items per page
const MAX_PAGE_LIMIT = 100; // Maximum number of items per page
const SORT_DEFAULT: [string, SortOrder][] = [["createdAt", -1]]; // Default sorting by createdAt in descending order
const EXCLUDED_QUERY_PARAMS = [
  "page",
  "sort",
  "fields",
  "keyword",
  "limit",
  "skip",
  "from",
  "to",
  "order",
  "_calculatedLimit",
]; // Query parameters to exclude from filtering

/**
 * ApiFeatures class to provide a set of query helpers for pagination, filtering, sorting, searching, and field selection
 * that are used with Mongoose queries.
 *
 * It allows to apply common query operations on a Mongoose query, making it reusable for different endpoints.
 */
export class ApiFeatures {
  // Mongoose query object that will be modified
  public mongooseQuery: Query<any, any>;

  // Query string from the request
  private queryString: QueryString;

  // Custom max limit override
  private customMaxLimit?: number;

  /**
   * Constructor to initialize the Mongoose query and query string.
   *
   * @param mongooseQuery - The Mongoose query object to modify.
   * @param queryString - The query string from the request containing query parameters like pagination, sorting, etc.
   */
  constructor(mongooseQuery: Query<any, any>, queryString: QueryString) {
    this.mongooseQuery = mongooseQuery;
    this.queryString = queryString;
  }

  /**
   * Sets a custom maximum limit for pagination.
   * This will override the default MAX_PAGE_LIMIT.
   *
   * @param limit - The new maximum limit
   * @returns The current instance of ApiFeatures to allow method chaining.
   */
  setMaxLimit(limit: number): this {
    if (limit > 0) {
      this.customMaxLimit = limit;
    }
    return this;
  }

  /**
   * Retrieves the page number from the query string.
   * Ensures the page number is a positive integer.
   *
   * @returns The page number from the query string, or 1 if not provided or invalid.
   */
  getPageNumber(): number {
    const pageParam = this.queryString.page;
    if (!pageParam) return 1;

    const page = parseInt(pageParam as unknown as string, 10);
    return isNaN(page) || page < 1 ? 1 : page;
  }

  /**
   * Applies pagination to the Mongoose query.
   * Supports both page-based and skip-based pagination.
   * Handles user-provided limits with a maximum of 100 items per page (or custom max limit if set).
   *
   * @returns The current instance of ApiFeatures to allow method chaining.
   */
  pagination(): this {
    const page = this.getPageNumber();

    // Calculate and store limit before deleting it
    const maxLimit = this.customMaxLimit || MAX_PAGE_LIMIT;
    const requestedLimit = parseInt(this.queryString.limit as unknown as string, 10) || PAGE_LIMIT;

    // If customMaxLimit is set, allow exceeding MAX_PAGE_LIMIT
    const limit = this.customMaxLimit
      ? Math.min(Math.max(1, requestedLimit), maxLimit)
      : Math.min(Math.max(1, requestedLimit), MAX_PAGE_LIMIT);

    // Calculate skip based on page and limit
    const skip = (page - 1) * limit;

    this.mongooseQuery.skip(skip).limit(limit);

    // Store the calculated limit in the queryString for later use
    this.queryString._calculatedLimit = limit;

    // Cleanup processed params
    delete this.queryString.skip;
    delete this.queryString.limit;

    return this;
  }

  /**
   * Applies filtering to the Mongoose query.
   * Supports standard MongoDB operators and date ranges.
   *
   * @returns The current instance of ApiFeatures to allow method chaining.
   */
  filteration(): this {
    let filterObj: { [key: string]: any } = { ...this.queryString };

    // Exclude non-filtering parameters
    EXCLUDED_QUERY_PARAMS.forEach((param) => {
      delete filterObj[param];
    });

    // Handle date range filtering
    if (filterObj.from || filterObj.to) {
      const dateFilter: { createdAt?: any } = {};

      if (filterObj.from) {
        try {
          const fromDate = new Date(decodeURIComponent(filterObj.from as string));
          if (!isNaN(fromDate.getTime())) {
            fromDate.setHours(0, 0, 0, 0);
            dateFilter.createdAt = { $gte: fromDate };
          }
        } catch (error) {
          console.error(`Error parsing 'from' date: ${filterObj.from}`, error);
        }
      }

      if (filterObj.to) {
        try {
          const toDate = new Date(decodeURIComponent(filterObj.to as string));
          if (!isNaN(toDate.getTime())) {
            toDate.setHours(23, 59, 59, 999);
            if (!dateFilter.createdAt) {
              dateFilter.createdAt = {};
            }
            dateFilter.createdAt.$lte = toDate;
          }
        } catch (error) {
          console.error(`Error parsing 'to' date: ${filterObj.to}`, error);
        }
      }

      filterObj = { ...filterObj, ...dateFilter };
      delete filterObj.from;
      delete filterObj.to;
    }

    // Convert MongoDB operators
    let stringifiedFilterObj = JSON.stringify(filterObj);
    stringifiedFilterObj = stringifiedFilterObj.replace(
      /\b(gt|gte|lt|lte|in|nin|eq|ne)\b/g,
      (match) => `$${match}`
    );
    filterObj = JSON.parse(stringifiedFilterObj);

    this.mongooseQuery.find(filterObj);
    return this;
  }

  /**
   * Applies sorting to the Mongoose query.
   * Supports standard URL search parameters for sorting.
   *
   * Examples:
   * - ?sort=name&order=asc
   * - ?sort=createdAt&order=desc
   * - ?sort=price,-createdAt (multiple fields with direction)
   *
   * @returns The current instance of ApiFeatures to allow method chaining.
   */
  sort(): this {
    try {
      // Handle multiple sort fields with direction prefixes
      if (this.queryString.sort) {
        const sortFields = this.queryString.sort.split(",");
        const sortObj: { [key: string]: SortOrder } = {};

        for (const field of sortFields) {
          // Check if field starts with - for descending order
          const isDesc = field.startsWith("-");
          const cleanField = isDesc ? field.substring(1) : field;

          // Validate if the field exists in the schema
          if (this.mongooseQuery.model.schema.paths[cleanField]) {
            sortObj[cleanField] = isDesc ? -1 : 1;
          } else {
            console.warn(`Invalid sort field: ${cleanField}`);
          }
        }

        // Only apply sort if we have valid fields
        if (Object.keys(sortObj).length > 0) {
          this.mongooseQuery.sort(sortObj);
          return this;
        }
      }

      // Handle single field sort with order parameter
      if (this.queryString.order && this.queryString.sort) {
        const order = this.queryString.order.toLowerCase() === "desc" ? -1 : 1;
        const sortField = this.queryString.sort;

        // Validate if the field exists in the schema
        if (this.mongooseQuery.model.schema.paths[sortField]) {
          this.mongooseQuery.sort({ [sortField]: order });
          return this;
        } else {
          console.warn(`Invalid sort field: ${sortField}`);
        }
      }

      // Default sort only if no valid sort parameters were provided
      this.mongooseQuery.sort({ [SORT_DEFAULT[0][0]]: SORT_DEFAULT[0][1] });
    } catch (error) {
      console.error("Error applying sorting:", error);
      // Fallback to default sort only on error
      this.mongooseQuery.sort({ [SORT_DEFAULT[0][0]]: SORT_DEFAULT[0][1] });
    }

    return this;
  }

  /**
   * Applies search functionality to the Mongoose query.
   * Searches across common fields using case-insensitive regex.
   *
   * @returns The current instance of ApiFeatures to allow method chaining.
   */
  search(): this {
    if (this.queryString.keyword) {
      const searchRegex = new RegExp(this.queryString.keyword, "i");
      const searchFields = COMMON_SEARCH_FIELDS.filter(
        (field) => this.mongooseQuery.model.schema.paths[field]
      );

      if (searchFields.length > 0) {
        const searchQuery = searchFields.map((field) => ({
          [field]: searchRegex,
        }));
        this.mongooseQuery.find({ $or: searchQuery });
      }
    }
    return this;
  }

  /**
   * Applies field selection to the Mongoose query.
   * Supports both inclusion and exclusion of fields.
   *
   * Examples:
   * - ?fields=name,price,description (include only these fields)
   * - ?fields=-createdAt,-updatedAt,-__v (exclude these fields)
   * - ?fields=name,price,-createdAt,-__v (include name and price, exclude createdAt and __v)
   *
   * @returns The current instance of ApiFeatures to allow method chaining.
   */
  fields(): this {
    if (this.queryString.fields) {
      const fields = this.queryString.fields
        .split(",")
        .map((field) => {
          // Check if field starts with - for exclusion
          const isExcluded = field.startsWith("-");
          const cleanField = isExcluded ? field.substring(1) : field;

          // Validate if the field exists in the schema
          if (!this.mongooseQuery.model.schema.paths[cleanField]) {
            console.warn(`Invalid field: ${cleanField}`);
            return null;
          }

          return isExcluded ? `-${cleanField}` : cleanField;
        })
        .filter(Boolean)
        .join(" " + " -__v");

      if (fields) {
        this.mongooseQuery.select(fields);
      }
    }
    return this;
  }

  /**
   * Executes the query and returns paginated results.
   * @param key - The key to use for the data array in the response (e.g., "customers", "orders")
   * @returns Paginated data with the specified key for the results array
   */
  async getPaginatedData<T>(key: string = "results"): Promise<PaginatedData<T>> {
    const page = this.getPageNumber();

    // Use the stored limit from pagination() or calculate it if not available
    const limit =
      this.queryString._calculatedLimit ||
      Math.min(
        Math.max(1, parseInt(this.queryString.limit as unknown as string, 10) || PAGE_LIMIT),
        MAX_PAGE_LIMIT
      );

    // Clone the query for count calculation
    const queryClone = this.mongooseQuery.model.find(this.mongooseQuery.getFilter());

    const [results, total] = await Promise.all([
      this.mongooseQuery.exec(),
      queryClone.countDocuments(),
    ]);

    // Calculate total pages based on the actual limit used
    const totalPages = Math.ceil(total / limit);

    return {
      [key]: results,
      pagination: {
        page,
        total,
        limit,
        totalPages,
      },
      filters: this.mongooseQuery.getFilter() as unknown as IFilter[],
      sort: this.mongooseQuery.getOptions().sort || {},
    };
  }
}
