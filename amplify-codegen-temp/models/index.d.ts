import { ModelInit, MutableModel, __modelMeta__, ManagedIdentifier } from "@aws-amplify/datastore";
// @ts-ignore
import { LazyLoading, LazyLoadingDisabled } from "@aws-amplify/datastore";





type EagerVideo = {
  readonly [__modelMeta__]: {
    identifier: ManagedIdentifier<Video, 'id'>;
    readOnlyFields: 'updatedAt';
  };
  readonly id: string;
  readonly title: string;
  readonly uploaderId: string;
  readonly s3Key: string;
  readonly createdAt?: string | null;
  readonly pic?: string | null;
  readonly sd?: boolean | null;
  readonly hd?: boolean | null;
  readonly s1?: string | null;
  readonly updatedAt?: string | null;
}

type LazyVideo = {
  readonly [__modelMeta__]: {
    identifier: ManagedIdentifier<Video, 'id'>;
    readOnlyFields: 'updatedAt';
  };
  readonly id: string;
  readonly title: string;
  readonly uploaderId: string;
  readonly s3Key: string;
  readonly createdAt?: string | null;
  readonly pic?: string | null;
  readonly sd?: boolean | null;
  readonly hd?: boolean | null;
  readonly s1?: string | null;
  readonly updatedAt?: string | null;
}

export declare type Video = LazyLoading extends LazyLoadingDisabled ? EagerVideo : LazyVideo

export declare const Video: (new (init: ModelInit<Video>) => Video) & {
  copyOf(source: Video, mutator: (draft: MutableModel<Video>) => MutableModel<Video> | void): Video;
}